import Component from "@glimmer/component";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import icon from "discourse/helpers/d-icon";
import number from "discourse/helpers/number";
import DiscourseURL from "discourse/lib/url";
import { i18n } from "discourse-i18n";
import ScholarPaperTabs from "./scholar-paper-tabs";

export default class PaperDetailPage extends Component {
  get paper() {
    return this.args.paper || {};
  }

  get authors() {
    return this.paper.authors || [];
  }

  get fieldsOfStudy() {
    return this.paper.fields_of_study || [];
  }

  get errorMessage() {
    return this.paper.error_message || i18n("scholar.paper.states.unavailable");
  }

  navigateTo(path) {
    DiscourseURL.routeTo(path);
  }

  <template>
    <div class="scholar-page paper-detail-page">
      {{#if this.paper.load_error}}
        <div class="paper-detail-page__error-card">
          <h2>{{i18n "scholar.paper.states.unavailable"}}</h2>
          <p>{{this.errorMessage}}</p>
        </div>
      {{else}}
        <div class="paper-detail-page__container">
          <main class="paper-detail-page__main">
            <article class="paper-detail-page__header-card">
              <div class="paper-detail-page__id-line">
                {{#if this.paper.doi}}
                  <span>DOI: {{this.paper.doi}}</span>
                {{/if}}
                {{#if this.paper.id}}
                  <span>Corpus ID: {{this.paper.id}}</span>
                {{/if}}
              </div>

              <h1 class="paper-detail-page__title">{{this.paper.title}}</h1>

              <div class="paper-detail-page__authors">
                {{#if this.authors.length}}
                  {{#each this.authors as |author|}}
                    {{#if author.path}}
                      <button
                        type="button"
                        class="paper-detail-page__author-link"
                        {{on "click" (fn this.navigateTo author.path)}}
                      >{{author.name}}</button>
                    {{else if author.url}}
                      <a
                        href={{author.url}}
                        target="_blank"
                        rel="noopener noreferrer"
                        class="paper-detail-page__author-link"
                      >{{author.name}}</a>
                    {{else}}
                      <span class="paper-detail-page__author-name">{{author.name}}</span>
                    {{/if}}
                  {{/each}}
                {{else}}
                  <span
                    class="paper-detail-page__no-data"
                  >{{i18n "scholar.paper.states.no_authors"}}</span>
                {{/if}}
              </div>

              <div class="paper-detail-page__pub-line">
                {{#if this.paper.venue}}
                  <span>{{i18n "scholar.paper.published_in"}}
                    <strong>{{this.paper.venue}}</strong></span>
                {{/if}}
                {{#if this.paper.publication_date}}
                  <span>{{this.paper.publication_date}}</span>
                {{else if this.paper.year}}
                  <span>{{this.paper.year}}</span>
                {{/if}}
              </div>

              {{#if this.fieldsOfStudy.length}}
                <div class="paper-detail-page__fields">
                  {{#each this.fieldsOfStudy as |field|}}
                    <span class="paper-detail-page__field">{{field}}</span>
                  {{/each}}
                </div>
              {{/if}}

              {{#if this.paper.abstract}}
                <div class="paper-detail-page__abstract">
                  <p>{{this.paper.abstract}}</p>
                </div>
              {{else}}
                <p
                  class="paper-detail-page__no-data"
                >{{i18n "scholar.paper.states.no_abstract"}}</p>
              {{/if}}

              <div class="paper-detail-page__actions">
                {{#if this.paper.url}}
                  <a
                    href={{this.paper.url}}
                    target="_blank"
                    rel="noopener noreferrer"
                    class="paper-detail-page__action-btn -primary"
                  >
                    {{icon "arrow-up-right-from-square"}}
                    {{i18n "scholar.paper.actions.view_source"}}
                  </a>
                {{/if}}
                {{#if this.paper.pdf_url}}
                  <a
                    href={{this.paper.pdf_url}}
                    target="_blank"
                    rel="noopener noreferrer"
                    class="paper-detail-page__action-btn"
                  >
                    {{icon "file-pdf"}}
                    {{i18n "scholar.paper.actions.open_pdf"}}
                  </a>
                {{/if}}
              </div>
            </article>

            <ScholarPaperTabs @paper={{this.paper}} />
          </main>

          <aside class="paper-detail-page__sidebar">
            <div class="paper-detail-page__sidebar-card">
              <div class="paper-detail-page__stat">
                <span class="paper-detail-page__stat-value">{{number
                    this.paper.citation_count
                  }}</span>
                <span class="paper-detail-page__stat-label">{{i18n
                    "scholar.paper.metrics.citations"
                  }}</span>
              </div>
            </div>

            <div class="paper-detail-page__sidebar-card">
              <div class="paper-detail-page__stat">
                <span class="paper-detail-page__stat-value">{{number
                    this.paper.reference_count
                  }}</span>
                <span class="paper-detail-page__stat-label">{{i18n
                    "scholar.paper.metrics.references"
                  }}</span>
              </div>
            </div>

            {{#if this.paper.is_open_access}}
              <div class="paper-detail-page__sidebar-card -open-access">
                {{icon "lock-open"}}
                <span>{{i18n "scholar.paper.metrics.open_access"}}</span>
              </div>
            {{/if}}

            <div class="paper-detail-page__sidebar-card -details">
              <h3>{{i18n "scholar.paper.sections.details"}}</h3>
              <dl class="paper-detail-page__details-list">
                {{#if this.paper.venue}}
                  <dt>{{i18n "scholar.paper.meta.venue"}}</dt>
                  <dd>{{this.paper.venue}}</dd>
                {{/if}}
                {{#if this.paper.year}}
                  <dt>{{i18n "scholar.paper.meta.year"}}</dt>
                  <dd>{{this.paper.year}}</dd>
                {{/if}}
                {{#if this.paper.publication_date}}
                  <dt>{{i18n "scholar.paper.meta.publication_date"}}</dt>
                  <dd>{{this.paper.publication_date}}</dd>
                {{/if}}
                {{#if this.paper.doi}}
                  <dt>{{i18n "scholar.paper.meta.doi"}}</dt>
                  <dd>
                    <a
                      href={{this.paper.doi_url}}
                      target="_blank"
                      rel="noopener noreferrer"
                    >{{this.paper.doi}}</a>
                  </dd>
                {{/if}}
              </dl>
            </div>
          </aside>
        </div>
      {{/if}}
    </div>
  </template>
}
