const functions = require("firebase-functions/v2");
const admin = require("firebase-admin");

// Inicjalizacja Firebase Admin SDK
admin.initializeApp();
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

      const deletePromises = files.map((file) => file.delete());
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
