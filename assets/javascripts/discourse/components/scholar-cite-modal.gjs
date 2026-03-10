import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import icon from "discourse/helpers/d-icon";
import { i18n } from "discourse-i18n";

const FORMAT_LABELS = {
  bibtex: "BibTeX",
  mla: "MLA",
  apa: "APA",
  chicago: "Chicago",
};

export default class ScholarCiteModal extends Component {
  @tracked activeFormat = "bibtex";
  @tracked copied = false;

  get paper() {
    return this.args.paper || {};
  }

  get authorNames() {
    const authors = this.paper.authors || [];
    return authors.map((a) => (typeof a === "string" ? a : a.name));
  }

  get citationText() {
    switch (this.activeFormat) {
      case "bibtex":
        return this.bibtex;
      case "mla":
        return this.mla;
      case "apa":
        return this.apa;
      case "chicago":
        return this.chicago;
      default:
        return this.bibtex;
    }
  }

  get bibtex() {
    const p = this.paper;
    const key = this.authorNames[0]?.split(" ").pop() || "unknown";
    const year = p.year || "n.d.";
    const lines = [`@article{${key}${year},`];
    lines.push(`  title={${p.title || ""}},`);
    if (this.authorNames.length) {
      lines.push(`  author={${this.authorNames.join(" and ")}},`);
    }
    if (p.venue) {
      lines.push(`  journal={${p.venue}},`);
    }
    lines.push(`  year={${year}},`);
    if (p.doi) {
      lines.push(`  doi={${p.doi}},`);
    }
    if (p.url) {
      lines.push(`  url={${p.url}}`);
    }
    lines.push("}");
    return lines.join("\n");
  }

  get mla() {
    const p = this.paper;
    const parts = [];
    if (this.authorNames.length) {
      parts.push(this.formatMlaAuthors());
    }
    parts.push(`"${p.title || ""}".`);
    if (p.venue) {
      parts.push(`${p.venue},`);
    }
    if (p.year) {
      parts.push(`${p.year}.`);
    }
    if (p.doi) {
      parts.push(`doi:${p.doi}.`);
    }
    return parts.join(" ");
  }

  get apa() {
    const p = this.paper;
    const parts = [];
    if (this.authorNames.length) {
      parts.push(this.formatApaAuthors());
    }
    if (p.year) {
      parts.push(`(${p.year}).`);
    }
    parts.push(`${p.title || ""}.`);
    if (p.venue) {
      parts.push(`${p.venue}.`);
    }
    if (p.doi) {
      parts.push(`https://doi.org/${p.doi}`);
    }
    return parts.join(" ");
  }

  get chicago() {
    const p = this.paper;
    const parts = [];
    if (this.authorNames.length) {
      parts.push(`${this.authorNames.join(", ")}.`);
    }
    parts.push(`"${p.title || ""}".`);
    if (p.venue) {
      parts.push(`${p.venue}`);
    }
    if (p.year) {
      parts.push(`(${p.year}).`);
    }
    if (p.doi) {
      parts.push(`https://doi.org/${p.doi}.`);
    }
    return parts.join(" ");
  }

  get formatTabs() {
    return Object.entries(FORMAT_LABELS).map(([key, label]) => ({
      key,
      label,
      active: key === this.activeFormat,
    }));
  }

  formatMlaAuthors() {
    const names = this.authorNames;
    if (names.length === 1) {
      return `${this.invertName(names[0])}.`;
    }
    if (names.length === 2) {
      return `${this.invertName(names[0])}, and ${names[1]}.`;
    }
    return `${this.invertName(names[0])}, et al.`;
  }

  formatApaAuthors() {
    const names = this.authorNames;
    const formatted = names.slice(0, 3).map((n) => this.initialName(n));
    if (names.length > 3) {
      formatted.push("...");
    }
    return `${formatted.join(", ")}.`;
  }

  invertName(name) {
    const parts = name.trim().split(/\s+/);
    if (parts.length < 2) {
      return name;
    }
    return `${parts[parts.length - 1]}, ${parts.slice(0, -1).join(" ")}`;
  }

  initialName(name) {
    const parts = name.trim().split(/\s+/);
    if (parts.length < 2) {
      return name;
    }
    const last = parts[parts.length - 1];
    const initials = parts
      .slice(0, -1)
      .map((p) => `${p[0]}.`)
      .join(" ");
    return `${last}, ${initials}`;
  }

  @action
  setFormat(format) {
    this.activeFormat = format;
    this.copied = false;
  }

  @action
  async copyText() {
    try {
      await navigator.clipboard.writeText(this.citationText);
      this.copied = true;
      setTimeout(() => {
        this.copied = false;
      }, 2000);
    } catch {
      const textarea = document.createElement("textarea");
      textarea.value = this.citationText;
      document.body.appendChild(textarea);
      textarea.select();
      document.execCommand("copy");
      document.body.removeChild(textarea);
      this.copied = true;
      setTimeout(() => {
        this.copied = false;
      }, 2000);
    }
  }

  @action
  close() {
    this.args.onClose?.();
  }

  @action
  handleOverlayClick(event) {
    if (event.target === event.currentTarget) {
      this.close();
    }
  }

  <template>
    <div
      class="scholar-cite-modal__overlay"
      {{on "click" this.handleOverlayClick}}
    >
      <div class="scholar-cite-modal">
        <div class="scholar-cite-modal__header">
          <h2 class="scholar-cite-modal__title">{{i18n
              "scholar.cite.title"
            }}</h2>
          <div class="scholar-cite-modal__tabs">
            {{#each this.formatTabs as |tab|}}
              <button
                type="button"
                class="scholar-cite-modal__tab
                  {{if tab.active '-active'}}"
                {{on "click" (fn this.setFormat tab.key)}}
              >{{tab.label}}</button>
            {{/each}}
          </div>
          <button
            type="button"
            class="scholar-cite-modal__close"
            {{on "click" this.close}}
          >{{icon "xmark"}}</button>
        </div>

        <div class="scholar-cite-modal__body">
          <pre class="scholar-cite-modal__code">{{this.citationText}}</pre>
        </div>

        <div class="scholar-cite-modal__footer">
          <button
            type="button"
            class="scholar-cite-modal__copy-btn"
            {{on "click" this.copyText}}
          >
            {{icon "copy"}}
            {{#if this.copied}}
              {{i18n "scholar.cite.copied"}}
            {{else}}
              {{i18n "scholar.cite.copy"}}
            {{/if}}
          </button>
        </div>
      </div>
    </div>
  </template>
}
