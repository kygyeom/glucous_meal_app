# Gemini Image Analysis Testing Guide

## ✨ Now Using Official Google Generative AI SDK

This implementation uses the official `google-generativeai` Python SDK for better reliability and easier integration!

## Setup

### 1. Activate Virtual Environment (if using venv)
```bash
# If you're using a virtual environment (e.g., .venv/glucous)
source .venv/glucous/bin/activate

# On Windows:
# .venv\glucous\Scripts\activate
```

### 2. Install Dependencies
```bash
# If using venv (virtual environment):
pip install google-generativeai Pillow

# If installing system-wide (not recommended):
# pip3 install --break-system-packages google-generativeai Pillow
```

### 3. Add Gemini API Key to .env
```bash
echo "GEMINI_API_KEY=your_actual_gemini_api_key_here" >> .env
```

Get a free API key from: https://aistudio.google.com/apikey

### 4. Start the Backend Server
```bash
python -m uvicorn main:app --reload
```

You should see:
```
✅ Google Generative AI configured with API key
INFO:     Uvicorn running on http://127.0.0.1:8000
```

### 5. Run the Flutter App
```bash
flutter run -d linux
# Or for mobile:
# flutter run -d <your_device_id>
```

## Testing the Feature

### Step 1: Open the App
- The main screen shows nutrition input fields
- Look for the button: **"사진으로 영양 정보 입력"** (Input nutrition from photo)

### Step 2: Take/Select Food Image
1. Click the camera button
2. Choose **"카메라"** (Camera) or **"갤러리"** (Gallery)
3. Grant permissions if prompted
4. Take a photo of food or select from gallery

### Step 3: Watch the Analysis
**In the terminal (backend logs), you'll see:**
```
============================================================
📸 New image analysis request
📁 Filename: image.jpg
📦 Content type: image/jpeg
============================================================

🔍 Starting Gemini image analysis with SDK...
📊 Image size: 123456 bytes
✅ API Key configured
✅ Image loaded: JPEG (1024, 768)
✅ Model initialized: gemini-1.5-flash
📤 Sending request to Gemini API via SDK...
✅ Received response from Gemini
📝 Generated text: {
  "food_name": "Grilled Chicken Breast"...
🔧 Cleaned text for parsing: {...
✅ Parsed JSON successfully
🍽️ Food detected: Grilled Chicken Breast

============================================================
✅ Analysis complete!
🍽️ Food: Grilled Chicken Breast
📝 Description: A healthy protein-rich meal...
🎯 Confidence: high
============================================================
```

**In the Flutter app logs:**
```
✅ Image analysis successful!
🍽️ Food detected: Grilled Chicken Breast
📝 Description: A healthy protein-rich meal consisting of...
🎯 Confidence: high
📊 Nutrition: {calories_kcal: 250, carbohydrate_g: 5, protein_g: 45...}
✅ Auto-filled nutrition fields
```

### Step 4: See Results on Screen
The app will display:
- **Large food name** in a prominent green box
- **Description** of the food
- **Confidence level** (high/medium/low) with star icons
- **Auto-filled nutrition values** in the input fields

### Step 5: Predict Glucose
- The nutrition fields should be auto-filled
- Click **"혈당 예측"** (Predict Glucose) to see glucose predictions

## Troubleshooting

### Error: "Gemini API key not configured"
- Make sure you added `GEMINI_API_KEY` to your `.env` file
- Restart the FastAPI server after adding the key
- Check the key is valid at https://aistudio.google.com/apikey

### Error: "Permission denied"
- Grant camera/photo permissions when prompted
- On Android 13+, grant "Photos and videos" permission
- On iOS, grant "Camera" and "Photos" permission

### Error: HTTP 400/403/404 from Gemini
- **Now using official SDK** - No more manual HTTP errors!
- Check your API key is correct and has Gemini API enabled
- Make sure the key is not rate-limited
- Verify the image is not too large (max 1024x1024 already set)
- Ensure you have the latest Gemini API access (free tier available)
- If you see import errors, run: `pip3 install --break-system-packages google-generativeai Pillow`

### No response from Gemini
- Check your internet connection
- Verify the API endpoint is accessible
- Look at backend terminal for detailed error messages

### Food name not displaying
- Check backend logs for successful parsing
- Check Flutter logs for received data
- Make sure the response contains `food_name` field

## Expected Behavior

1. **Camera/Gallery opens** when button clicked
2. **"이미지 분석 중..."** shows while processing
3. **Backend logs** print detailed analysis steps
4. **Green box appears** with detected food name (large, prominent)
5. **Nutrition fields auto-fill** with estimated values
6. **Success message** shows: "[Food Name]이(가) 인식되었습니다!"

## Example Foods to Test

- Grilled chicken
- Pizza
- Salad
- Rice bowl
- Sandwich
- Fruit
- Korean dishes (비빔밥, 김치찌개, etc.)

## API Rate Limits

Gemini API free tier:
- 15 requests per minute
- 1,500 requests per day
- 1 million tokens per day

If you hit rate limits, wait a minute and try again.
