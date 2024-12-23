const functions = require("firebase-functions/v2");
const admin = require("firebase-admin");

// Inicjalizacja Firebase Admin SDK
admin.initializeApp();
const db = admin.firestore();
const storage = admin.storage();

// Funkcja zwiększająca licznik po dodaniu pliku
exports.onRecordingUpload = functions.storage.onObjectFinalized(
  async (event) => {
    try {
      const filePath = event.name; // Ścieżka pliku w Firebase Storage
      console.log(`Plik przesłany: ${filePath}`);

      // Rozdzielamy ścieżkę na części
      const pathParts = filePath.split("/");
      const userId = pathParts[0]; // ID użytkownika
      const recordingType = pathParts[1]; // Typ nagrania (individualSamples, individualPasswords, sharedPasswords)

      // Sprawdzamy, czy typ nagrania jest poprawny
      const validTypes = [
        "individualSamples",
        "individualPasswords",
        "sharedPasswords",
      ];
      if (!validTypes.includes(recordingType)) {
        console.log(`Nieprawidłowy typ nagrania: ${recordingType}`);
        return;
      }

      // Zwiększamy odpowiedni licznik w Firestore
      const userRef = db.collection("users").doc(userId);
      const fieldToIncrement = `recordingCounts.${recordingType}`;
      await userRef.update({
        [fieldToIncrement]: admin.firestore.FieldValue.increment(1),
      });

      console.log(
        `Licznik zaktualizowany dla użytkownika ${userId}, typ: ${recordingType}`
      );
    } catch (error) {
      console.error("Błąd podczas aktualizacji licznika nagrań:", error);
    }
  }
);

// Funkcja zmniejszająca licznik po usunięciu pliku
exports.onRecordingDelete = functions.storage.onObjectDeleted(async (event) => {
  try {
    const filePath = event.name; // Ścieżka pliku w Firebase Storage
    console.log(`Plik usunięty: ${filePath}`);

    // Rozdzielamy ścieżkę na części
    const pathParts = filePath.split("/");
    const userId = pathParts[0]; // ID użytkownika
    const recordingType = pathParts[1]; // Typ nagrania (individualSamples, individualPasswords, sharedPasswords)

    // Sprawdzamy, czy typ nagrania jest poprawny
    const validTypes = [
      "individualSamples",
      "individualPasswords",
      "sharedPasswords",
    ];
    if (!validTypes.includes(recordingType)) {
      console.log(`Nieprawidłowy typ nagrania: ${recordingType}`);
      return;
    }

    // Zmniejszamy odpowiedni licznik w Firestore
    const userRef = db.collection("users").doc(userId);
    const fieldToDecrement = `recordingCounts.${recordingType}`;
    await userRef.update({
      [fieldToDecrement]: admin.firestore.FieldValue.increment(-1),
    });

    console.log(
      `Licznik zmniejszony dla użytkownika ${userId}, typ: ${recordingType}`
    );
  } catch (error) {
    console.error("Błąd podczas zmniejszania licznika nagrań:", error);
  }
});
