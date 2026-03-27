Feature: Decommission Asset

  Background:
    Given I am on the Asset detail screen for "Rooftop HVAC Unit" with Status "Active"

  Scenario: Facility Manager decommissions an Active Asset
    When I tap the Decommission button
    Then I see a confirmation dialog
    When I confirm decommission with reason "End of service life"
    Then the Asset detail screen shows Status "Decommissioned"
    And the Decommission button is no longer visible

  Scenario: Decommission button is not shown for an already-Decommissioned Asset
    Given the Asset has Status "Decommissioned"
    Then the Decommission button is not visible

  Scenario: Decommission confirmation dialog can be cancelled
    When I tap the Decommission button
    Then I see a confirmation dialog
    When I tap Cancel
    Then the Asset detail screen is still shown with Status "Active"
    And the Assets service is not called
