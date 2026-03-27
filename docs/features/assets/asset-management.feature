Feature: Asset Management
  In order to maintain an accurate registry of equipment under management
  As a platform user operating within a Tenant
  I want to view and register Assets

  Background:
    Given the platform is operating for Tenant "dev-tenant"
    And the API gateway is available at "http://localhost:8000"

  # ─── Asset List ─────────────────────────────────────────────────────────────

  Scenario: Asset list displays registered Assets using Tenant Values
    Given the following Assets are registered for Tenant "dev-tenant":
      | Name           | Canonical Asset Type | Tenant Asset Type Display | Facility ID  | Status |
      | Rooftop HVAC-1 | HVAC                 | Split System AC           | facility-001 | Active |
      | Boiler Unit 2  | Boiler               | Gas Boiler                | facility-001 | Active |
    When a Technician opens the Asset list screen
    Then the Asset list shows 2 Assets
    And each Asset displays its name
    And each Asset displays the Tenant Value for its Asset Type
    And the Canonical Asset Type is not displayed directly to the user

  Scenario: Asset list shows a loading indicator while fetching Assets
    Given the Assets service has not yet responded
    When a Technician opens the Asset list screen
    Then a loading indicator is visible

  Scenario: Asset list shows an empty state when no Assets are registered
    Given no Assets are registered for Tenant "dev-tenant"
    When a Technician opens the Asset list screen
    Then an empty state message is displayed

  Scenario: Asset list shows an error state when the Assets service is unavailable
    Given the Assets service is unavailable
    When a Technician opens the Asset list screen
    Then an error message is displayed
    And a trace ID is shown for support reference

  # ─── Register Asset ─────────────────────────────────────────────────────────

  Scenario: Facility Manager navigates to the Register Asset form
    Given a Facility Manager is on the Asset list screen
    When the Facility Manager taps "Register Asset"
    Then the Register Asset form is displayed
    And the form contains fields for Name, Asset Type, and Facility

  Scenario: Facility Manager registers a new Asset successfully
    Given a Facility Manager is on the Register Asset form
    When the Facility Manager enters the following Asset details:
      | Field       | Value          |
      | Name        | Rooftop HVAC-3 |
      | Asset Type  | HVAC           |
      | Facility ID | facility-001   |
    And the Facility Manager submits the Register Asset form
    Then the Asset "Rooftop HVAC-3" is added to the Asset registry
    And the Facility Manager is returned to the Asset list screen
    And the Asset list includes "Rooftop HVAC-3"

  Scenario: Register Asset form shows client-side validation errors for missing required fields
    Given a Facility Manager is on the Register Asset form
    When the Facility Manager submits the form without entering any fields
    Then field-level validation errors are shown for Name, Asset Type, and Facility
    And the form is not submitted to the Assets service

  Scenario: Register Asset form shows a server validation error with trace ID
    Given a Facility Manager is on the Register Asset form
    And the Assets service returns a 422 Unprocessable Entity response
    When the Facility Manager submits the Register Asset form with valid field values
    Then a validation error message is displayed
    And a trace ID is shown for support reference
    And the Facility Manager remains on the Register Asset form
