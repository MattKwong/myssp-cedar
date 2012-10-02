Feature: liaison navigation
  In order to give liaisons access to their information
  As a liaison user
  I want to go directly to my portal page
  Scenario: Liaison logon
    Given a valid liaison logon
    When I log on
    Then I see a personalized welcome message
  Scenario: Attempt to access unauthorized churches page
    Given a logged on "Liaison"
    When I visit "Churches"
    Then the page has a flash
    And I see an unauthorized message
  Scenario: Attempt to access unauthorized church page
    Given a logged on "Liaison"
    When I visit a church other than my own
    Then the page has a flash
    And I see an unauthorized message
  Scenario: Seeing a registration
    Given a valid liaison logon with a registered group
    When I log on
    Then I see a personalized welcome message
    And I see the registration name
  Scenario: Seeing a scheduled group
    Given a valid liaison logon with a scheduled group
    When I log on
    Then I see a personalized welcome message
    And I see the scheduled group name
