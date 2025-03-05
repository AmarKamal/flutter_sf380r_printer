package com.amastsales.flutter_sf380r_printer

import android.bluetooth.BluetoothDevice
import android.content.Context

import android.graphics.BitmapFactory
import android.os.Handler
import com.mht.print.sdk.Barcode
import com.mht.print.sdk.PrinterConstants
import com.mht.print.sdk.PrinterInstance
import com.mht.print.sdk.Table


class BluetoothOperation(
        private val context: Context,
        private val handler: Handler
) {
    private var printerInstance: PrinterInstance? = null

    fun connectPrinter(device: BluetoothDevice): Boolean {
        return try {
            printerInstance = PrinterInstance(context, device, handler)
            printerInstance?.openConnection()
            printerInstance?.isConnected ?: false

        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }

    fun isConnected(): Boolean {
        return printerInstance?.isConnected ?: false
    }

    fun disconnect() {
        printerInstance?.closeConnection()
        printerInstance = null
    }

    fun getPrinterInstance(): PrinterInstance? = printerInstance

    fun printText(text: String, alignment: Int = 0,  // Default to left alignment
            bold: Boolean = false, underline: Boolean = false, doubleWidth: Boolean = false, doubleHeight: Boolean = false, smallFont: Boolean = false,
    ): Boolean {
        return try {
            printerInstance?.let { printer ->
                // Initialize printer
                printer.init()

                // IMPORTANT: First explicitly cancel all previous formatting
                // ESC @ - Initialize printer (resets all settings)
                printer.sendByteData(byteArrayOf(0x1B, 0x40))

                // Then set alignment
                when (alignment) {
                    0 -> printer.setPrinter(PrinterConstants.Command.ALIGN, PrinterConstants.Command.ALIGN_LEFT)
                    1 -> printer.setPrinter(PrinterConstants.Command.ALIGN, PrinterConstants.Command.ALIGN_CENTER)
                    2 -> printer.setPrinter(PrinterConstants.Command.ALIGN, PrinterConstants.Command.ALIGN_RIGHT)
                    else -> printer.setPrinter(PrinterConstants.Command.ALIGN, PrinterConstants.Command.ALIGN_LEFT)
                }

                // Apply bold formatting only if requested
                if (bold) {
                    // ESC E 1 - Turn emphasized mode on
                    printer.sendByteData(byteArrayOf(0x1B, 0x45, 1))
                } else {
                    // ESC E 0 - Turn emphasized mode off (explicitly)
                    printer.sendByteData(byteArrayOf(0x1B, 0x45, 0))
                }

                // Apply underline formatting
                if (underline) {
                    // ESC - 1 - Turn underline mode on (1-dot thick)
                    printer.sendByteData(byteArrayOf(0x1B, 0x2D, 1))
                } else {
                    // ESC - 0 - Turn underline mode off (explicitly)
                    printer.sendByteData(byteArrayOf(0x1B, 0x2D, 0))
                }

                // Set character size
                printer.setCharacterMultiple(
                        if (doubleWidth) 1 else 0,
                        if (doubleHeight) 1 else 0
                )

                // Apply small font if requested
                if (smallFont) {
                    printer.setPrintModel(true, false, false, false, false)
                }

                // Print the text
                printer.printText(text)

                // Ensure the text is printed
                printer.setPrinter(PrinterConstants.Command.PRINT_AND_NEWLINE)

                // IMPORTANT: After printing, explicitly reset all formatting to default
                // ESC @ - Initialize printer again
                printer.sendByteData(byteArrayOf(0x1B, 0x40))

                true
            } ?: false
        } catch (e: Exception) {
            android.util.Log.e("PrinterPlugin", "Print text error: ${e.message}")
            e.printStackTrace()
            false
        }
    }

    fun printQRCode(content: String, moduleSize: Int, alignment: Int = 0): Boolean {
        return try {
            printerInstance?.let {
                it.init()

                // Set alignment for the QR code
                val alignValue = when(alignment) {
                    1 -> PrinterConstants.Command.ALIGN_CENTER
                    2 -> PrinterConstants.Command.ALIGN_RIGHT
                    else -> PrinterConstants.Command.ALIGN_LEFT
                }

                it.setPrinter(PrinterConstants.Command.ALIGN, alignValue)

                val qrcode = Barcode(PrinterConstants.BarcodeType.QRCODE)
                qrcode.setQrcodeSize(moduleSize)
                qrcode.setBarcodeContent(content)
                it.printBarCode(qrcode)
                it.setPrinter(PrinterConstants.Command.PRINT_AND_NEWLINE)

                it.setPrinter(PrinterConstants.Command.ALIGN, PrinterConstants.Command.ALIGN_LEFT)

                true
            } ?: false
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }

    fun printBarcode(content: String, type: Int, width: Int, height: Int, position: Int, alignment: Int = 0): Boolean {
        return try {
            printerInstance?.let {
                it.init()

                // Set alignment for the barcode
                val alignValue = when(alignment) {
                    1 -> PrinterConstants.Command.ALIGN_CENTER
                    2 -> PrinterConstants.Command.ALIGN_RIGHT
                    else -> PrinterConstants.Command.ALIGN_LEFT
                }

                it.setPrinter(PrinterConstants.Command.ALIGN, alignValue)

                val barcodeType = when (type) {
                    0 -> PrinterConstants.BarcodeType.UPC_A
                    1 -> PrinterConstants.BarcodeType.UPC_E
                    2 -> PrinterConstants.BarcodeType.JAN13
                    3 -> PrinterConstants.BarcodeType.JAN8
                    4 -> PrinterConstants.BarcodeType.CODE39
                    5 -> PrinterConstants.BarcodeType.ITF
                    6 -> PrinterConstants.BarcodeType.CODABAR
                    7 -> PrinterConstants.BarcodeType.CODE93
                    else -> PrinterConstants.BarcodeType.CODE128
                }
                val barcode = Barcode(barcodeType, width, height, position, content)
                it.printBarCode(barcode)
                it.setPrinter(PrinterConstants.Command.PRINT_AND_NEWLINE)

                // Reset alignment to left
                it.setPrinter(PrinterConstants.Command.ALIGN, PrinterConstants.Command.ALIGN_LEFT)


                true
            } ?: false
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }

    fun printImage(base64Image: String,alignment: Int = 0): Boolean {
        return try {
            printerInstance?.let {
                it.init()

                val alignValue = when(alignment){
                    1 -> PrinterConstants.Command.ALIGN_CENTER
                    2 -> PrinterConstants.Command.ALIGN_RIGHT
                    else ->  PrinterConstants.Command.ALIGN_LEFT
                }

                it.setPrinter(PrinterConstants.Command.ALIGN,alignValue)

                // Log that we're trying to decode the image
                android.util.Log.d("PrinterPlugin", "Decoding image data")

                // Decode base64 string to byte array with error checking
                val decodedBytes = try {
                    android.util.Base64.decode(base64Image, android.util.Base64.DEFAULT)
                } catch (e: Exception) {
                    android.util.Log.e("PrinterPlugin", "Base64 decoding failed: ${e.message}")
                    return false
                }

                // Log the size of the decoded data
                android.util.Log.d("PrinterPlugin", "Decoded image size: ${decodedBytes.size} bytes")

                // Set up bitmap options to handle potential issues
                val options = BitmapFactory.Options().apply {
                    inPreferredConfig = android.graphics.Bitmap.Config.RGB_565 // Use less memory
                }

                // Decode the byte array into a bitmap
                val bitmap = try {
                    BitmapFactory.decodeByteArray(decodedBytes, 0, decodedBytes.size, options)
                } catch (e: Exception) {
                    android.util.Log.e("PrinterPlugin", "Bitmap decoding failed: ${e.message}")
                    return false
                }

                // Check if bitmap was successfully created
                if (bitmap == null) {
                    android.util.Log.e("PrinterPlugin", "Failed to create bitmap from image data")
                    return false
                }

                // Log bitmap dimensions
                android.util.Log.d("PrinterPlugin", "Bitmap dimensions: ${bitmap.width}x${bitmap.height}")

                // Check if the bitmap is too large for a typical thermal printer
                val maxWidth = 384 // Standard width for many thermal receipt printers
                val scaledBitmap = if (bitmap.width > maxWidth) {
                    // Scale down if too wide
                    val ratio = maxWidth.toFloat() / bitmap.width
                    val newHeight = (bitmap.height * ratio).toInt()
                    android.util.Log.d("PrinterPlugin", "Scaling bitmap to ${maxWidth}x${newHeight}")
                    android.graphics.Bitmap.createScaledBitmap(bitmap, maxWidth, newHeight, true)
                } else {
                    bitmap
                }

                // Print the bitmap
                it.printEscImage(scaledBitmap)
                it.setPrinter(PrinterConstants.Command.PRINT_AND_NEWLINE)
                it.setPrinter(PrinterConstants.Command.ALIGN, PrinterConstants.Command.ALIGN_LEFT)

                // Clean up bitmaps
                if (scaledBitmap != bitmap) {
                    scaledBitmap.recycle()
                }
                bitmap.recycle()

                true
            } ?: false
        } catch (e: Exception) {
            android.util.Log.e("PrinterPlugin", "Error printing image: ${e.message}")
            e.printStackTrace()
            false
        }
    }

    fun printTable(columns: List<String>, columnWidths: List<Int>, rows: List<List<String>>): Boolean {
        return try {
            printerInstance?.let {
                it.init()

                // Create column header string with ";" separator
                val columnHeader = columns.joinToString(";")

                // Create Table instance
                val table = Table(columnHeader, ";", columnWidths.toIntArray())

                // Add rows
                for (row in rows) {
                    table.addRow(row.joinToString(";"))
                }

                it.printTable(table)
                it.setPrinter(PrinterConstants.Command.PRINT_AND_NEWLINE)
                true
            } ?: false
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }


    fun setEncoding(encoding: String): Boolean {
        return try {
            printerInstance?.let {
                it.encoding = encoding  // Use method instead of property assignment
                true
            } ?: false
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }

    fun getPrinterStatus(): Int {
        return printerInstance?.printerStatus ?: -1
    }
}