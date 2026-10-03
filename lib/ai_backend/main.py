import os
import uuid

import edge_tts

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse
from pydantic import BaseModel
from dotenv import load_dotenv


# =========================================================
# ENVIRONMENT
# =========================================================

load_dotenv()


# =========================================================
# FASTAPI APP
# =========================================================

app = FastAPI(
    title="AI Food Assistant Backend",
    description="Python FastAPI + Edge-TTS backend for Flutter Food Delivery App",
    version="1.0.0",
)


# =========================================================
# CORS
# =========================================================

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# =========================================================
# AUDIO SETTINGS
# =========================================================

AUDIO_DIR = "generated_audio"

os.makedirs(
    AUDIO_DIR,
    exist_ok=True
)


# =========================================================
# EDGE-TTS VOICES
# =========================================================

URDU_VOICE = "ur-PK-UzmaNeural"

ENGLISH_VOICE = "en-US-JennyNeural"


# =========================================================
# REQUEST MODELS
# =========================================================

class VoiceRequest(BaseModel):
    text: str
    language: str = "English"


class ChatRequest(BaseModel):
    message: str
    language: str = "English"


# =========================================================
# VOICE SELECTOR
# =========================================================

def get_voice(language: str) -> str:

    if language.strip().lower() == "urdu":
        return URDU_VOICE

    return ENGLISH_VOICE


# =========================================================
# GENERATE VOICE
# =========================================================

async def generate_voice(
    text: str,
    language: str
) -> str:

    if not text.strip():
        raise ValueError(
            "Text cannot be empty."
        )

    voice = get_voice(
        language
    )

    filename = (
        f"{uuid.uuid4().hex}.mp3"
    )

    filepath = os.path.join(
        AUDIO_DIR,
        filename
    )

    communicate = edge_tts.Communicate(
        text=text,
        voice=voice,
        rate="+0%",
        volume="+0%",
        pitch="+0Hz",
    )

    await communicate.save(
        filepath
    )

    return filename


# =========================================================
# ROOT
# =========================================================

@app.get("/")
async def root():

    return {
        "success": True,
        "message": "AI Food Assistant Backend is running.",
        "version": "1.0.0",
        "urdu_voice": URDU_VOICE,
        "english_voice": ENGLISH_VOICE,
        "endpoints": {
            "health": "/health",
            "voice": "/voice",
            "chat": "/chat",
            "audio": "/audio/{filename}",
            "docs": "/docs",
        },
    }


# =========================================================
# HEALTH CHECK
# =========================================================

@app.get("/health")
async def health():

    return {
        "success": True,
        "status": "healthy",
        "service": "AI Food Assistant",
    }


# =========================================================
# VOICE API
# =========================================================

@app.post("/voice")
async def create_voice(
    request: VoiceRequest
):

    try:

        text = request.text.strip()

        language = request.language.strip()

        # -------------------------------------------------
        # Validate text
        # -------------------------------------------------

        if not text:

            raise HTTPException(
                status_code=400,
                detail="Text is required."
            )

        # -------------------------------------------------
        # Generate MP3
        # -------------------------------------------------

        filename = await generate_voice(
            text=text,
            language=language
        )

        # -------------------------------------------------
        # Full URL for Flutter
        # -------------------------------------------------

        audio_url = (
            f"http://127.0.0.1:8000/audio/{filename}"
        )

        return {
            "success": True,
            "message": "Voice generated successfully.",
            "language": language,
            "voice": get_voice(language),
            "filename": filename,
            "audio_url": audio_url,
        }

    except HTTPException:

        raise

    except Exception as e:

        print(
            "VOICE ERROR:",
            str(e)
        )

        raise HTTPException(
            status_code=500,
            detail=str(e)
        )


# =========================================================
# AUDIO FILE API
# =========================================================

@app.get("/audio/{filename}")
async def get_audio(
    filename: str
):

    try:

        filepath = os.path.join(
            AUDIO_DIR,
            filename
        )

        # -------------------------------------------------
        # Security / file existence check
        # -------------------------------------------------

        if not os.path.exists(filepath):

            raise HTTPException(
                status_code=404,
                detail="Audio file not found."
            )

        # -------------------------------------------------
        # Return MP3
        # -------------------------------------------------

        return FileResponse(
            filepath,
            media_type="audio/mpeg",
            filename=filename,
        )

    except HTTPException:

        raise

    except Exception as e:

        print(
            "AUDIO ERROR:",
            str(e)
        )

        raise HTTPException(
            status_code=500,
            detail=str(e)
        )


# =========================================================
# DEMO AI RESPONSE
# =========================================================

def generate_demo_response(
    message: str,
    language: str
) -> str:

    lower_message = message.lower()

    # =====================================================
    # URDU
    # =====================================================

    if language.strip().lower() == "urdu":

        # -------------------------------------------------
        # Budget
        # -------------------------------------------------

        if (
            "500" in lower_message
            or "پانچ سو" in message
        ):

            return (
                "جی بالکل! آپ پانچ سو روپے کے اندر "
                "برگر، زنگر برگر یا چکن رول آرڈر کر سکتے ہیں۔"
            )

        # -------------------------------------------------
        # Spicy
        # -------------------------------------------------

        if (
            "spicy" in lower_message
            or "spicy food" in lower_message
            or "مرچ" in message
            or "مصالحے" in message
        ):

            return (
                "اگر آپ کو مصالحے دار کھانا پسند ہے "
                "تو زنگر برگر، چکن تکہ یا اسپائسی رول "
                "اچھے آپشنز ہیں۔"
            )

        # -------------------------------------------------
        # Order
        # -------------------------------------------------

        if (
            "order" in lower_message
            or "آرڈر" in message
        ):

            return (
                "جی ضرور! میں آپ کے تازہ ترین آرڈر کی "
                "معلومات چیک کرنے میں آپ کی مدد کر سکتا ہوں۔"
            )

        # -------------------------------------------------
        # Menu
        # -------------------------------------------------

        if (
            "menu" in lower_message
            or "کھانا" in message
            or "مینو" in message
        ):

            return (
                "جی ضرور! میں آپ کو دستیاب کھانے کی چیزیں "
                "دکھا سکتا ہوں۔ آپ برگر، پیزا، بروست یا "
                "دیگر آئٹمز تلاش کر سکتے ہیں۔"
            )

        # -------------------------------------------------
        # Greeting
        # -------------------------------------------------

        if (
            "hello" in lower_message
            or "hi" in lower_message
            or "salam" in lower_message
            or "السلام" in message
        ):

            return (
                "وعلیکم السلام! میں آپ کا AI فوڈ اسسٹنٹ ہوں۔ "
                "میں آپ کو کھانا تلاش کرنے، ڈشز تجویز کرنے "
                "اور آرڈر کرنے میں مدد کر سکتا ہوں۔"
            )

        # -------------------------------------------------
        # Default
        # -------------------------------------------------

        return (
            "جی ضرور! میں آپ کے لیے کھانے کی چیزیں تلاش کرنے، "
            "بہترین ڈشز تجویز کرنے اور آرڈر کرنے میں مدد "
            "کر سکتا ہوں۔"
        )

    # =====================================================
    # ENGLISH
    # =====================================================

    else:

        # -------------------------------------------------
        # Budget
        # -------------------------------------------------

        if (
            "500" in lower_message
            or "under 500" in lower_message
            or "below 500" in lower_message
        ):

            return (
                "Sure! You can find burgers, zinger burgers, "
                "and chicken rolls under 500 rupees."
            )

        # -------------------------------------------------
        # Spicy
        # -------------------------------------------------

        if (
            "spicy" in lower_message
            or "hot food" in lower_message
        ):

            return (
                "If you like spicy food, I recommend a "
                "zinger burger, spicy chicken, or a "
                "chicken roll."
            )

        # -------------------------------------------------
        # Order
        # -------------------------------------------------

        if (
            "order" in lower_message
            or "my order" in lower_message
        ):

            return (
                "Sure! I can help you check your latest order."
            )

        # -------------------------------------------------
        # Menu
        # -------------------------------------------------

        if (
            "menu" in lower_message
            or "food" in lower_message
            or "available" in lower_message
        ):

            return (
                "Sure! I can help you explore our available "
                "food items including burgers, pizza, broast, "
                "drinks, and more."
            )

        # -------------------------------------------------
        # Greeting
        # -------------------------------------------------

        if (
            "hello" in lower_message
            or "hi" in lower_message
            or "hey" in lower_message
        ):

            return (
                "Hello! 👋 I am your AI Food Assistant. "
                "I can help you find food, recommend dishes, "
                "and place your order."
            )

        # -------------------------------------------------
        # Default
        # -------------------------------------------------

        return (
            "Sure! I can help you find food, recommend dishes, "
            "check available items, and help with your orders."
        )


# =========================================================
# CHAT API
# =========================================================

@app.post("/chat")
async def chat(
    request: ChatRequest
):

    try:

        message = request.message.strip()

        language = request.language.strip()

        # -------------------------------------------------
        # Validate message
        # -------------------------------------------------

        if not message:

            raise HTTPException(
                status_code=400,
                detail="Message is required."
            )

        # -------------------------------------------------
        # Generate AI response
        # -------------------------------------------------

        response_text = generate_demo_response(
            message=message,
            language=language
        )

        # -------------------------------------------------
        # Generate Edge-TTS voice
        # -------------------------------------------------

        filename = await generate_voice(
            text=response_text,
            language=language
        )

        # -------------------------------------------------
        # Full audio URL for Flutter
        # -------------------------------------------------

        audio_url = (
            f"http://127.0.0.1:8000/audio/{filename}"
        )

        # -------------------------------------------------
        # Return response
        # -------------------------------------------------

        return {
            "success": True,
            "user_message": message,
            "response": response_text,
            "language": language,
            "voice": get_voice(language),
            "audio_url": audio_url,
            "filename": filename,
        }

    except HTTPException:

        raise

    except Exception as e:

        print(
            "CHAT ERROR:",
            str(e)
        )

        raise HTTPException(
            status_code=500,
            detail=str(e)
        )


# =========================================================
# SERVER START
# =========================================================

if __name__ == "__main__":

    import uvicorn

    print("")
    print("=" * 60)
    print("      AI FOOD ASSISTANT BACKEND")
    print("=" * 60)
    print("")
    print("Server:  http://127.0.0.1:8000")
    print("Docs:    http://127.0.0.1:8000/docs")
    print("Health:  http://127.0.0.1:8000/health")
    print("")
    print("English Voice:", ENGLISH_VOICE)
    print("Urdu Voice:   ", URDU_VOICE)
    print("")
    print("=" * 60)
    print("")

    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=8000,
        reload=True,
    )