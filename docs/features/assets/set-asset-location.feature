Feature: Set Asset Location

  Background:
    Given I am on the Asset detail screen for "Rooftop HVAC Unit"

  Scenario: Facility Manager sets a Location on an Asset
    When I tap the Set Location button
    Then I see the Set Location form
    When I enter facility ID "facility-001" and location ID "roof-level-3"
    And I tap Save
    Then I see the Asset detail screen showing location "roof-level-3"

  Scenario: Set Location form shows validation error when location ID is blank
    When I tap the Set Location button
    And I clear the location ID field
    And I tap Save
    Then I see a validation error "Location is required"
    And the Assets service is not called

  Scenario: Set Location form pre-fills current values when a location is already set
    Given the Asset already has location "roof-level-3" in Facility "facility-001"
    When I tap the Set Location button
    Then the location ID field is pre-filled with "roof-level-3"
    And the facility ID field is pre-filled with "facility-001"
