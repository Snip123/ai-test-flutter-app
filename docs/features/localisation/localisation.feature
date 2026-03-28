Feature: Localisation
  In order to use the platform in their preferred language
  As a user operating within a Tenant
  I want the platform UI to be available in English, French, German, and Arabic

  Background:
    Given the platform is operating for Tenant "dev-tenant"
    And the API gateway is available at "http://localhost:8000"

  # ─── Language Selection ──────────────────────────────────────────────────────

  Scenario: Platform defaults to the device locale when supported
    Given the device locale is set to "fr-FR"
    When a user opens the platform
    Then the UI is rendered in French

  Scenario: Platform defaults to English when device locale is not supported
    Given the device locale is set to "es-ES"
    When a user opens the platform
    Then the UI is rendered in English

  Scenario: User changes the display language from a settings control
    Given a user is on any screen with a language selector
    When the user selects "Deutsch" from the language selector
    Then the UI is immediately re-rendered in German
    And the selected language persists across app restarts

  Scenario Outline: All four supported locales are available for selection
    When a user opens the language selector
    Then the following locales are listed:
      | Locale | Display Name    |
      | en     | English         |
      | fr     | Français        |
      | de     | Deutsch         |
      | ar     | العربية         |

  # ─── RTL Layout — Arabic ─────────────────────────────────────────────────────

  Scenario: Arabic locale renders the full UI in a right-to-left layout
    Given the selected locale is "ar"
    When a user opens any screen
    Then the layout direction is right-to-left
    And the app bar title is aligned to the right
    And navigation icons are mirrored appropriately

  Scenario: Switching away from Arabic restores left-to-right layout
    Given the selected locale is "ar"
    And the user switches the locale to "en"
    When any screen is displayed
    Then the layout direction is left-to-right

  # ─── Asset List Screen ───────────────────────────────────────────────────────

  Scenario Outline: Asset list screen renders all UI strings in the selected locale
    Given the selected locale is "<locale>"
    When a user opens the Asset list screen
    Then the screen title shows "<title>"
    And the "Register Asset" button label shows "<register_btn>"
    And the empty state message shows "<empty_state>"
    Examples:
      | locale | title   | register_btn         | empty_state                        |
      | en     | Assets  | Register Asset       | No Assets registered yet.          |
      | fr     | Actifs  | Enregistrer un actif | Aucun actif enregistré pour l'instant. |
      | de     | Anlagen | Anlage registrieren  | Noch keine Anlagen registriert.    |
      | ar     | الأصول  | تسجيل أصل            | لا توجد أصول مسجلة حتى الآن.      |

  Scenario Outline: Asset list error state renders in the selected locale
    Given the selected locale is "<locale>"
    And the Assets service is unavailable
    When a user opens the Asset list screen
    Then an error message is displayed in "<locale>"
    And a trace ID is shown for support reference
    Examples:
      | locale |
      | en     |
      | fr     |
      | de     |
      | ar     |

  # ─── Asset Detail Screen ─────────────────────────────────────────────────────

  Scenario Outline: Asset detail screen renders field labels in the selected locale
    Given the selected locale is "<locale>"
    And an Asset exists for Tenant "dev-tenant"
    When a user opens the Asset detail screen
    Then the field labels for Name, Asset Type, Status, Facility, Location, and Serial Number are rendered in "<locale>"
    And the "Set Location" button label is rendered in "<locale>"
    Examples:
      | locale |
      | en     |
      | fr     |
      | de     |
      | ar     |

  Scenario Outline: Decommission confirmation dialog renders in the selected locale
    Given the selected locale is "<locale>"
    And a user is on the Asset detail screen
    When the user taps the decommission action
    Then the confirmation dialog title, message, and button labels are rendered in "<locale>"
    Examples:
      | locale |
      | en     |
      | fr     |
      | de     |
      | ar     |

  # ─── Register Asset Screen ───────────────────────────────────────────────────

  Scenario Outline: Register Asset form renders field labels and hints in the selected locale
    Given the selected locale is "<locale>"
    When a Facility Manager opens the Register Asset form
    Then the form title, field labels, and hint text are rendered in "<locale>"
    Examples:
      | locale |
      | en     |
      | fr     |
      | de     |
      | ar     |

  Scenario Outline: Register Asset validation messages render in the selected locale
    Given the selected locale is "<locale>"
    And a Facility Manager is on the Register Asset form
    When the Facility Manager submits the form without entering any fields
    Then the validation error messages for Name, Asset Type, and Facility are rendered in "<locale>"
    Examples:
      | locale |
      | en     |
      | fr     |
      | de     |
      | ar     |

  # ─── Edit Asset Screen ───────────────────────────────────────────────────────

  Scenario Outline: Edit Asset form renders in the selected locale
    Given the selected locale is "<locale>"
    And a Facility Manager is on the Edit Asset form
    Then the form title, field labels, and Save button are rendered in "<locale>"
    Examples:
      | locale |
      | en     |
      | fr     |
      | de     |
      | ar     |

  # ─── Set Asset Location Screen ───────────────────────────────────────────────

  Scenario Outline: Set Location form renders in the selected locale
    Given the selected locale is "<locale>"
    When a user opens the Set Location form
    Then the form title, field labels, hints, and Set Location button are rendered in "<locale>"
    Examples:
      | locale |
      | en     |
      | fr     |
      | de     |
      | ar     |

  # ─── Tenant Values are not localised ────────────────────────────────────────

  Scenario: Tenant Values are displayed as configured by the Tenant, not translated
    Given the Tenant has configured Asset Type Tenant Value "Split System AC" for Canonical Asset Type "HVAC"
    And the selected locale is "fr"
    When a user views an Asset with Canonical Asset Type "HVAC"
    Then the Asset Type displayed is "Split System AC"
    And it is not translated to French

  # ─── Locale Persistence ─────────────────────────────────────────────────────

  Scenario: Selected locale persists after the app is closed and reopened
    Given a user has selected "de" as their locale
    When the user closes and reopens the app
    Then the UI is rendered in German without requiring re-selection
