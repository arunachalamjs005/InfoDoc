# Quick OCR Test Guide

## 🚀 Quick Test (Run These Commands)

```bash
# 1. Uninstall old app (important!)
adb uninstall com.example.infodoc_app

# 2. Clean and rebuild
flutter clean
flutter pub get

# 3. Run the app
flutter run
```

## 📝 Testing Steps

### Test 1: Camera OCR
1. Open the app
2. Tap the **"+"** button
3. Tap **"Camera"** (green icon)
4. Grant camera permission
5. Take a photo of text (book, sign, document)
6. Tap **"Proceed"**
7. **First time**: May show "Downloading OCR language data..."
   - Wait 10-30 seconds
   - Try again with another image
8. **Second time**: Should extract text successfully ✅

### Test 2: Upload OCR
1. Tap **"+"** button
2. Tap **"Upload"** (purple icon)
3. Grant storage permission
4. Select image with text from gallery
5. Tap **"Proceed"**
6. Should extract text (or download data if first time)

## ✅ Expected Results

### First OCR Attempt:
- May show: "Downloading OCR language data... Please try again in a moment."
- This is NORMAL - language data is being downloaded
- Wait and try again

### Second OCR Attempt:
- Should show: "Extracting text from image..."
- Then: "Text extraction complete!"
- Results screen shows extracted text in **Claim** section ✅

## 🐛 If Still Getting Errors

### Error: "OCR initialization error"
**Solution**: 
1. Check internet connection
2. Wait 30 seconds and try again
3. Language data is downloading in background

### Error: "Permission denied"
**Solution**:
1. Go to device Settings → Apps → InfoDoc
2. Grant Camera and Storage permissions
3. Try again

### Error: "No text detected"
**Solution**:
1. Use image with clear, readable text
2. Ensure good lighting
3. Text should be horizontal
4. Try with a book page or printed document

## 📊 What Should Work Now

| Feature | Status |
|---------|--------|
| Camera capture | ✅ Working |
| Upload from gallery | ✅ Working |
| Permission requests | ✅ Working |
| OCR text extraction | ✅ Working (after first download) |
| Results display | ✅ Working |

## 🔍 Check Logs

To see what's happening:
```bash
flutter logs
```

Look for:
- "OCR Error:" messages
- Tesseract download progress
- Permission grant/deny messages

## 💡 Pro Tips

1. **First time use**: Be patient, language data needs to download
2. **Best images**: High contrast, clear text, good lighting
3. **Permissions**: Grant all permissions when asked
4. **Internet**: Ensure device has internet for first use

---

**Ready to test!** Run the commands above and test OCR functionality.
