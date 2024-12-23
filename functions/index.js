const functions = require("firebase-functions/v2");
const admin = require("firebase-admin");

// Inicjalizacja Firebase Admin SDK
admin.initializeApp();
const db = admin.firestore();
const storage = admin.storage();

// Funkcja obsługująca usuwanie wszystkich plików użytkownika po jego usunięciu
exports.onUserDelete = functions.firestore.onDocumentDeleted(
  "users/{userId}",
  async (event) => {
    const userId = event.params.userId;
    const userFolderPath = `${userId}/`;

    try {
      const [files] = await storage
        .bucket()
        .getFiles({ prefix: userFolderPath });

      // Oznaczamy usuwanie plików metadanymi
      const deletePromises = files.map((file) =>
        file
          .setMetadata({
            metadata: {
              skipTrigger: "true", // Metadane, które oznaczają plik do pominięcia w onRecordingDelete
            },
          })
          .then(() => file.delete())
      );

      await Promise.all(deletePromises);

      console.log(
        `Wszystkie pliki i foldery dla użytkownika ${userId} zostały usunięte.`
      );
    } catch (error) {
      console.error(
        `Błąd podczas usuwania plików dla użytkownika ${userId}:`,
        error
      );
    }
  }
);

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
    const filePath = event.data.name; // Ścieżka pliku
    const metadata = event.data.metadata || {}; // Pobieramy metadane pliku
    const skipTrigger = metadata.skipTrigger === "true"; // Sprawdzamy flagę skipTrigger

    if (!filePath) {
      console.error("Ścieżka pliku jest niezdefiniowana.");
      return;
    }

    if (skipTrigger) {
      console.log(`Usunięcie pliku pominięte: ${filePath}`);
      return; // Pomijamy, jeśli plik został oznaczony do pominięcia
    }

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
