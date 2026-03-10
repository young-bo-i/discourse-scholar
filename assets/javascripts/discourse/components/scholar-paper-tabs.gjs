import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import didInsert from "@ember/render-modifiers/modifiers/did-insert";
import number from "discourse/helpers/number";
import { ajax } from "discourse/lib/ajax";
import DiscourseURL from "discourse/lib/url";
import { i18n } from "discourse-i18n";

export default class ScholarPaperTabs extends Component {
  @tracked activeTab = "citations";
  @tracked citationPapers = null;
  @tracked referencePapers = null;
  @tracked relatedPapers = null;
  @tracked loading = false;

  get paper() {
    return this.args.paper || {};
  }

  get paperId() {
    return this.paper.route_id || this.paper.id;
  }

  get currentItems() {
    if (this.activeTab === "citations") {
      return this.citationPapers;
    }
    if (this.activeTab === "references") {
      return this.referencePapers;
    }
    return this.relatedPapers;
  }

  get emptyMessageKey() {
    return `scholar.paper.tabs.no_${this.activeTab}`;
  }

  get isCitationsActive() {
    return this.activeTab === "citations";
  }

  get isReferencesActive() {
    return this.activeTab === "references";
  }

  get isRelatedActive() {
    return this.activeTab === "related";
  }

  @action
  onInsert() {
    this.loadTab("citations");
  }

  @action
  switchTab(tab) {
    if (this.activeTab === tab) {
      return;
    }
    this.activeTab = tab;
    this.loadTab(tab);
  }

  @action
  navigateTo(path) {
    DiscourseURL.routeTo(path);
  }

  async loadTab(tab) {
    const dataMap = {
      citations: "citationPapers",
      references: "referencePapers",
      related: "relatedPapers",
    };

    const prop = dataMap[tab];
    if (this[prop] !== null) {
      return;
    }

    if (!this.paperId) {
      return;
    }

    this.loading = true;
    try {
      const result = await ajax(
        `/scholar/paper/${this.paperId}/${tab}.json`
      );
      this[prop] = result.papers || [];
    } catch {
      this[prop] = [];
    } finally {
      this.loading = false;
    }
  }

  <template>
    <section class="scholar-paper-tabs" {{didInsert this.onInsert}}>
      <div class="scholar-paper-tabs__header">
        <button
          type="button"
          class="scholar-paper-tabs__tab {{if this.isCitationsActive '-active'}}"
          {{on "click" (fn this.switchTab "citations")}}
        >
          {{i18n "scholar.paper.tabs.citations"}}
          {{#if this.paper.citation_count}}
            ({{number this.paper.citation_count}})
          {{/if}}
        </button>
        <button
          type="button"
          class="scholar-paper-tabs__tab {{if this.isReferencesActive '-active'}}"
          {{on "click" (fn this.switchTab "references")}}
        >
          {{i18n "scholar.paper.tabs.references"}}
          {{#if this.paper.reference_count}}
            ({{number this.paper.reference_count}})
          {{/if}}
        </button>
        <button
          type="button"
          class="scholar-paper-tabs__tab {{if this.isRelatedActive '-active'}}"
          {{on "click" (fn this.switchTab "related")}}
        >
          {{i18n "scholar.paper.tabs.related"}}
        </button>
      </div>

      <div class="scholar-paper-tabs__content">
        {{#if this.loading}}
          <p class="scholar-paper-tabs__loading">{{i18n
              "scholar.paper.tabs.loading"
            }}</p>
        {{else if this.currentItems}}
          {{#if this.currentItems.length}}
            <div class="scholar-paper-tabs__list">
              {{#each this.currentItems as |paper|}}
                <article class="scholar-result-card">
                  <button
                    type="button"
                    class="scholar-result-card__link"
                    {{on "click" (fn this.navigateTo paper.path)}}
                  >
                    <h3 class="scholar-result-card__title">{{paper.title}}</h3>
                  </button>
                  <div class="scholar-result-card__meta">
                    {{#if paper.authors}}
                      <span class="scholar-result-card__authors">{{paper.authors}}</span>
                    {{/if}}
                    {{#if paper.venue}}
                      <span class="scholar-result-card__venue">{{paper.venue}}</span>
                    {{/if}}
                    {{#if paper.year}}
                      <span class="scholar-result-card__year">{{paper.year}}</span>
                    {{/if}}
                  </div>
                  {{#if paper.citation_count}}
                    <span class="scholar-result-card__citations">
                      {{number paper.citation_count}}
                      {{i18n "scholar.paper.metrics.citations"}}
                    </span>
                  {{/if}}
                </article>
              {{/each}}
            </div>
          {{else}}
            <p class="scholar-paper-tabs__empty">{{i18n this.emptyMessageKey}}</p>
          {{/if}}
        {{/if}}
      </div>
    </section>
  </template>
}
