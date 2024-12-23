# Voice Vault App

Voice Vault is a mobile application handling three variants of a multifactor voice-based authentication system. It enables secure user registration and login using advanced voice recognition technologies. The application provides multiple authentication variants to test and evaluate the balance between security and usability.

## Key Features

- **User Registration**: Register with your name, email, and voice samples.
- **Three Authentication Variants**:
  1. **Baseline Variant**: Simple voice verification (Speaker Verification - SV) with speech content analysis (ASR).
  2. **Advanced Variant**: Enhanced SV using x-vectors with adaptive fusion logic.
  3. **Contextual Variant**: Combines advanced SV with additional contextual questions and optional deepfake detection.
- **Authentication System Selection**: Choose and test different variants of the authentication process directly from the app.
- **Cloud Integration**: Securely store user data and audio files using Firebase.
- **Dynamic Recording Management**: Add, play, or delete voice samples.

## Technology Stack

- **Frontend**: Flutter (Android & iOS support)
- **Backend**: Firebase (Firestore, Storage, Cloud Functions)
- **Audio Processing**: Google Cloud Functions
- **Voice Models**:
  - **Speaker Verification**:
    - GMM-UBM
    - x-vectors (ECAPA-TDNN, TitaNet-L)
  - **Automatic Speech Recognition (ASR)**:
    - Whisper (OpenAI)

## Getting Started

1. Clone the repository:
   ```bash
   git clone https://github.com/conrad-push/voice-vault.git
