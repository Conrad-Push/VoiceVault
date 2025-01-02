import 'package:flutter/material.dart';

/// Application colors (used globally across the app)
class AppColors {
  static const Color background = Color(0xFFEFEFEF); // Light gray background
  static const Color primary = Color(0xFF5A7D9A); // Navy blue
  static const Color error = Color.fromARGB(255, 215, 81, 81); // Red
  static const Color disabled = Color(0xFFB0BEC5); // Disabled button color
}

/// Application texts
class AppTexts {
  // Button texts
  static const String loginButton = 'Zaloguj';
  static const String registerButton = 'Zarejestruj';
  static const String cancelButton = 'Anuluj';

  // Home screen
  static const String homeTitle = 'Lista użytkowników';

  // Registration screen
  static const String registrationTitle = 'Rejestracja';
  static const String nameLabel = 'Imię/pseudonim';
  static const String nameHelperText = 'Wpisz swoje imię lub pseudonim';
  static const String emailLabel = 'Adres e-mail';
  static const String emailHelperText = 'Podaj swój e-mail';
  static const String registrationSuccess = 'Rejestracja zakończona sukcesem';

  // Registration contents for individual samples
  static const String individualSample1Text =
      'Świadomie zgadzam się na użycie mojego głosu w badaniach naukowych, mających na celu rozwijanie systemów rozpoznawania mowy i głosu w języku polskim.\n\nOświadczam, że jestem świadom, iż wszystkie pliki nagraniowe zostaną bezpiecznie usunięte po zakończeniu analizy, a ich zawartość nie będzie udostępniona osobom trzecim.\n\nZdaję sobie sprawę, że dane głosowe zawierają szczególne cechy, takie jak barwa, intonacja i akcent, oraz że mogą posłużyć do lepszego zrozumienia specyfiki języka polskiego. Rozumiem również, że proces przetwarzania danych głosowych odbywa się z wykorzystaniem zaawansowanych technologii sztucznej inteligencji, które wymagają precyzyjnych i różnorodnych próbek do dalszego doskonalenia algorytmów. Dzięki temu naukowcy są w stanie identyfikować subtelne różnice w mowie, które mają kluczowe znaczenie dla jakości i skuteczności systemów rozpoznawania głosu.\n\nDzięki temu rozwijane technologie zapewnią wyższy poziom bezpieczeństwa i przyczynią się do zwiększenia świadomości na temat użycia nowoczesnych narzędzi w życiu codziennym. Wierzę, że takie badania mają potencjał nie tylko wspierać codzienne interakcje człowieka z technologią, ale także znaleźć zastosowanie w obszarach wymagających szczególnej precyzji, takich jak medycyna, edukacja czy zarządzanie kryzysowe.\n\nWyrażam zgodę z pełną świadomością i troską o przyszłość polskiej nauki.';
  static const String individualSample2Text =
      'Sztuczna inteligencja, choć niesie wiele możliwości, może stwarzać poważne zagrożenia. Szczególnie niebezpieczne są sytuacje, w których zaawansowane algorytmy przetwarzają mowę i tworzą klony głosów ludzi.\n\nWykorzystując takie technologie, oszuści mogą podszywać się pod osoby publiczne lub prywatne, szerząc fałszywe treści czy wprowadzając w błąd odbiorców. Klonowanie głosu staje się problemem globalnym, zwłaszcza gdy nagrania zawierają słowa charakterystyczne dla danego języka, jak "śmiech", "cisza" czy "szczęście".\n\nTechnologie te mogą być wykorzystywane nie tylko do oszustw finansowych, lecz także do manipulacji głosami celebrytów czy polityków, co może prowadzić do nieprzewidzianych skutków społecznych i politycznych.\n\nCo więcej, generowane syntetycznie wypowiedzi często brzmią naturalnie, przez co nawet doświadczeni słuchacze mogą mieć trudności z ich odróżnieniem od autentycznych nagrań.\n\nAby przeciwdziałać takim działaniom, specjaliści pracują nad systemami wykrywającymi, czy dźwięk jest autentyczny, czy sztucznie wytworzony. Takie podejście daje nadzieję na skuteczną ochronę przed manipulacjami głosowymi w przyszłości.';
  static const String individualSample3Text =
      'Wieloczynnikowe systemy biometryczne zyskują na znaczeniu dzięki swojej skuteczności i przyjazności dla użytkowników. Głos, jako unikalna cecha każdego człowieka, odgrywa szczególną rolę w procesie uwierzytelniania.\n\nW języku polskim, dźwięczne głoski, takie jak "śpiew", "szczebiot", czy "ciężar", nadają głosowi indywidualny charakter. Rozwiązania biometryczne umożliwiają rozpoznawanie takich niuansów, co czyni je trudnymi do sfałszowania. Dzięki zaawansowanym algorytmom systemy te są w stanie wykrywać subtelne różnice w intonacji, które wyróżniają głos konkretnego użytkownika nawet w warunkach zewnętrznych zakłóceń.\n\nRozpoznawanie takie zapewnia niezawodność działania, a jednocześnie pozwala zachować naturalność interakcji, co jest kluczowe w kontekście codziennego użytkowania nowoczesnych technologii. Połączenie analizy głosu z innymi czynnikami, jak analiza treści mowy czy dodatkowe pytania, gwarantuje wysoki poziom bezpieczeństwa przy zachowaniu wygody.\n\nW świecie pełnym zagrożeń, technologie te mogą chronić dane osobowe i zwiększać świadomość społeczną, ukazując, jak zaawansowana nauka wspiera codzienne życie.';
}
