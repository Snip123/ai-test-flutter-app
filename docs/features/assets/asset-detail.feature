Feature: View Asset Detail

  Background:
    Given I am on the Asset list screen
    And an Asset "Rooftop HVAC Unit" exists with ID "asset-001"

  Scenario: Facility Manager views Asset detail
    When I tap on "Rooftop HVAC Unit" in the Asset list
    Then I see the Asset detail screen for "Rooftop HVAC Unit"
    And the detail screen shows the Tenant Value for Asset Type
    And the detail screen shows the Tenant Value for Status
    And the detail screen shows the Facility ID

  Scenario: Asset detail shows a loading indicator while fetching
    When I tap on "Rooftop HVAC Unit" in the Asset list
    Then I see a loading indicator

  Scenario: Asset detail shows an error state with trace ID when the service is unavailable
    Given the Assets service is unavailable
    When I tap on "Rooftop HVAC Unit" in the Asset list
    Then I see an error message
    And I see the trace ID for support reference
