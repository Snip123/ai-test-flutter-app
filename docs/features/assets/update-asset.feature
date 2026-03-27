Feature: Update Asset Attributes

  Background:
    Given I am on the Asset detail screen for "Rooftop HVAC Unit"

  Scenario: Facility Manager updates Asset name and serial number
    When I tap the Edit button
    Then I see the Edit Asset form pre-filled with the current values
    When I update the name to "Rooftop HVAC Unit - R1"
    And I tap Save
    Then I see the Asset detail screen showing name "Rooftop HVAC Unit - R1"

  Scenario: Edit Asset form shows validation error when name is blank
    When I tap the Edit button
    And I clear the name field
    And I tap Save
    Then I see a validation error "Name is required"
    And the Assets service is not called

  Scenario: Edit Asset form shows a server error with trace ID
    When I tap the Edit button
    And I update the name to "Bad Name"
    And the Assets service returns a 422 error
    And I tap Save
    Then I see a server error message
    And I see the trace ID for support reference
