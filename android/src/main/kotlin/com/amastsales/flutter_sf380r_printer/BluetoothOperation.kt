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

//    fun setTextAlignment(alignment: Int): Boolean {
//        return try {
//            printerInstance?.let { printer ->
//                // Ensure the printer is initialized
//                printer.init()
//
//                android.util.Log.d("PrinterPlugin", "Setting alignment: $alignment")
//
//                // Set alignment based on the input
//                val result = when (alignment) {
//                    0 -> { // Left
//                        printer.setPrinter(PrinterConstants.Command.ALIGN, PrinterConstants.Command.ALIGN_LEFT)
//                    }
//                    1 -> { // Center
//                        printer.setPrinter(PrinterConstants.Command.ALIGN, PrinterConstants.Command.ALIGN_CENTER)
//                    }
//                    2 -> { // Right
//                        printer.setPrinter(PrinterConstants.Command.ALIGN, PrinterConstants.Command.ALIGN_RIGHT)
//                    }
//                    else -> {
//                        printer.setPrinter(PrinterConstants.Command.ALIGN, PrinterConstants.Command.ALIGN_LEFT)
//                    }
//                }
//
//                true
//            } ?: false
//        } catch (e: Exception) {
//            android.util.Log.e("PrinterPlugin", "Alignment Error: ${e.message}")
//            e.printStackTrace()
//            false
//        }
//    }

//    fun printWithAlignment(text: String, alignment: Int): Boolean {
//        return try {
//            printerInstance?.let { printer ->
//                // Initialize
//                printer.init()
//
//                // Set alignment
//                when (alignment) {
//                    0 -> printer.setPrinter(PrinterConstants.Command.ALIGN, PrinterConstants.Command.ALIGN_LEFT)
//                    1 -> printer.setPrinter(PrinterConstants.Command.ALIGN, PrinterConstants.Command.ALIGN_CENTER)
//                    2 -> printer.setPrinter(PrinterConstants.Command.ALIGN, PrinterConstants.Command.ALIGN_RIGHT)
//                    else -> printer.setPrinter(PrinterConstants.Command.ALIGN, PrinterConstants.Command.ALIGN_LEFT)
//                }
//
//                // Immediately print text
//                printer.printText(text)
//                printer.setPrinter(PrinterConstants.Command.PRINT_AND_NEWLINE)
//
//                true
//            } ?: false
//        } catch (e: Exception) {
//            android.util.Log.e("PrinterPlugin", "Print with Alignment Error: ${e.message}")
//            e.printStackTrace()
//            false
//        }
//    }

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

//    fun printBoldText(text: String, bold: Boolean): Boolean {
//        return try {
//            printerInstance?.let { printer ->
//                printer.init()
//
//                // ESC E n - Turn emphasized mode on/off
//                // n = 1: emphasized (bold) on, n = 0: emphasized off
//                val boldCmd = byteArrayOf(0x1B, 0x45, if (bold) 1.toByte() else 0.toByte())
//                printer.sendByteData(boldCmd)
////                printer.setPrintModel(false,bold,false,false,false) //.setPrintModel(false, bold, false, false, false)=
//
//                // Print the text
//                printer.printText(text)
//                printer.setPrinter(PrinterConstants.Command.PRINT_AND_NEWLINE)
//
//                true
//            } ?: false
//        } catch (e: Exception) {
//            android.util.Log.e("PrinterPlugin", "Print bold text error: ${e.message}")
//            e.printStackTrace()
//            false
//        }
//    }

//    fun printUnderlinedText(text: String, underline: Boolean): Boolean {
//        return try {
//            printerInstance?.let { printer ->
//                printer.init()
//
//                // ESC - n - Turn underline mode on/off
//                // n = 0: off, n = 1: 1-dot underline, n = 2: 2-dot underline
//                val underlineCmd = byteArrayOf(0x1B, 0x2D, if (underline) 1.toByte() else 0.toByte())
//                printer.sendByteData(underlineCmd)
//
//                // Print the text
//                printer.printText(text)
//                printer.setPrinter(PrinterConstants.Command.PRINT_AND_NEWLINE)
//
//                true
//            } ?: false
//        } catch (e: Exception) {
//            android.util.Log.e("PrinterPlugin", "Print underlined text error: ${e.message}")
//            e.printStackTrace()
//            false
//        }
//    }

//    fun printSizedText(text: String, widthScale: Int, heightScale: Int): Boolean {
//        return try {
//            printerInstance?.let { printer ->
//                printer.init()
//
//                // Text size scaling
//                // Valid values for both width and height are 0 to 7
//                // Limit the values to the valid range
//                val width = maxOf(0, minOf(7, widthScale))
//                val height = maxOf(0, minOf(7, heightScale))
//
//                // ESC ! n - Select print mode
//                // The value of n is calculated based on different formatting options
//                // For size, we're using the lower 4 bits: 0-3 for height, 4-7 for width
//                val sizeValue = (width shl 4) or height
//                val sizeCmd = byteArrayOf(0x1B, 0x21, sizeValue.toByte())
//
//                try {
//                    // Try to use write method if available
//                    printer.sendByteData(sizeCmd)
//                } catch (e: Exception) {
//                    // Fall back to setCharacterMultiple if write is not available
//                    printer.setCharacterMultiple(if (width > 0) 1 else 0, if (height > 0) 1 else 0)
//                }
//
//                // Print the text
//                printer.printText(text)
//                printer.setPrinter(PrinterConstants.Command.PRINT_AND_NEWLINE)
//
//                true
//            } ?: false
//        } catch (e: Exception) {
//            android.util.Log.e("PrinterPlugin", "Print sized text error: ${e.message}")
//            e.printStackTrace()
//            false
//        }
//    }

//    fun printFormattedText(
//            text: String,
//            alignment: Int,
//            bold: Boolean,
//            underline: Boolean,
//            doubleHeight: Boolean,
//            doubleWidth: Boolean,
//            smallFont: Boolean
//    ): Boolean {
//        return try {
//            printerInstance?.let { printer ->
//                printer.init()
//
//                // Set alignment
//                when (alignment) {
//                    0 -> printer.setPrinter(PrinterConstants.Command.ALIGN, PrinterConstants.Command.ALIGN_LEFT)
//                    1 -> printer.setPrinter(PrinterConstants.Command.ALIGN, PrinterConstants.Command.ALIGN_CENTER)
//                    2 -> printer.setPrinter(PrinterConstants.Command.ALIGN, PrinterConstants.Command.ALIGN_RIGHT)
//                    else -> printer.setPrinter(PrinterConstants.Command.ALIGN, PrinterConstants.Command.ALIGN_LEFT)
//                }
//
//                // Set character size
//                printer.setCharacterMultiple(if (doubleWidth) 1 else 0, if (doubleHeight) 1 else 0)
//
//                // Set text style
//                printer.setPrintModel(smallFont, bold, doubleHeight, doubleWidth, underline)
//
//                // Print the text
//                printer.printText(text)
//                printer.setPrinter(PrinterConstants.Command.PRINT_AND_NEWLINE)
//
//                true
//            } ?: false
//        } catch (e: Exception) {
//            android.util.Log.e("PrinterPlugin", "Print formatted text error: ${e.message}")
//            e.printStackTrace()
//            false
//        }
//    }

//    fun flushCommand(): Boolean {
//        return try {
//            printerInstance?.let {
//                it.setPrinter(PrinterConstants.Command.PRINT_AND_NEWLINE, 1)
//                true
//            } ?: false
//        } catch (e: Exception) {
//            android.util.Log.e("PrinterPlugin", "Flush Error: ${e.message}")
//            e.printStackTrace()
//            false
//        }
//    }

//    fun setCharacterMultiple(x: Int, y: Int): Boolean {
//        return try {
//            printerInstance?.let {
//                it.setCharacterMultiple(x, y)
//                true
//            } ?: false
//        } catch (e: Exception) {
//            e.printStackTrace()
//            false
//        }
//    }

//    fun setPrintModel(smallFont: Boolean, isBold: Boolean, isDoubleHeight: Boolean,
//                      isDoubleWidth: Boolean, isUnderLine: Boolean): Boolean {
//        return try {
//            printerInstance?.let {
//                it.init() // Ensure printer is initialized
//
//                // Log the formatting parameters for debugging
//                android.util.Log.d("PrinterPlugin", "Setting print model: " +
//                        "smallFont=$smallFont, " +
//                        "bold=$isBold, " +
//                        "doubleHeight=$isDoubleHeight, " +
//                        "doubleWidth=$isDoubleWidth, " +
//                        "underline=$isUnderLine")
//
//                // Attempt to set print model
//                val result = it.setPrintModel(
//                        smallFont,
//                        isBold,
//                        isDoubleHeight,
//                        isDoubleWidth,
//                        isUnderLine
//                )
//
//                // Additional verification
//                android.util.Log.d("PrinterPlugin", "Print model set result: $result")
//
//                true
//            } ?: false
//        } catch (e: Exception) {
//            android.util.Log.e("PrinterPlugin", "Print Model Error: ${e.message}")
//            e.printStackTrace()
//            false
//        }
//    }

    fun getPrinterStatus(): Int {
        return printerInstance?.printerStatus ?: -1
    }
}