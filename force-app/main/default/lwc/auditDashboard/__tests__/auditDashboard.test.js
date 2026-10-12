import { createElement } from "lwc";
import AuditDashboard from "c/auditDashboard";

describe("c-audit-dashboard", () => {
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
  });

  it("shows the landing page with a Run Scan button before a scan starts", () => {
    const element = createElement("c-audit-dashboard", { is: AuditDashboard });
    document.body.appendChild(element);

    const title = element.shadowRoot.querySelector(".title");
    expect(title.textContent).toBe("Sentinel Dashboard");

    const button = element.shadowRoot.querySelector("lightning-button");
    expect(button.label).toBe("Run Scan");

    // The dashboard card only appears after a scan has started
    expect(element.shadowRoot.querySelector("lightning-card")).toBeNull();
  });
});
