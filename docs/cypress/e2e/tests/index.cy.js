/// <reference types="cypress" />

describe("hello world test", () => {
  //block of tests
  it("test home", () => {
    cy.visit("https://staging-docs.airqo.net/#/");
  });
});
