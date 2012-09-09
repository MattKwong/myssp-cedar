Feature: a liaison initiates the new registration process Steps 1 through 3
  In order for groups to register for a session
  As a valid liaison for a church
  I want to start the creation of a new group registration
  Scenario: Liaison confirms basic church and contact info
    Given a logged on "Liaison"
    When I click on "Register a Group"
    Then I see the "Register a New Group" page
    And I see the "Step 1" current section
  Scenario: Completing Step 1
    Given a liaison in Step 1
    When I select a group type and click "Continue"
    Then I see the "New Registration" page
    And I see the "Step 2" current section
  Scenario: Completing Step 2
    Given a liaison in Step 2
    When I input youth and counselor values
    Then I see the "New Registration" page
    And I see the "Step 3" current section