import Component from "@glimmer/component";
import { fn } from "@ember/helper";
import number from "discourse/helpers/number";
import DiscourseURL from "discourse/lib/url";
import { i18n } from "discourse-i18n";
import ScholarSearchBox from "./scholar-search-box";

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

  get sourceLabel() {
    return this.paper.source?.toUpperCase();
  }

  get errorMessage() {
    return this.paper.error_message || i18n("scholar.paper.states.unavailable");
  }

  navigateTo(path) {
    DiscourseURL.routeTo(path);
  }

  <template>
    <div class="scholar-page paper-detail-page">
      <ScholarSearchBox />

      {{#if this.paper.load_error}}
        <section class="paper-detail-page__layout">
          <article class="paper-detail-page__card">
            <h2>{{i18n "scholar.paper.states.unavailable"}}</h2>
            <p class="paper-detail-page__empty">
              {{this.errorMessage}}
            </p>
          </article>
        </section>
      {{else}}
      <section class="paper-detail-page__hero">
        <div class="paper-detail-page__hero-content">
          <div class="paper-detail-page__eyebrow">
            {{#if this.sourceLabel}}
              <span class="paper-detail-page__badge">{{this.sourceLabel}}</span>
            {{/if}}

            {{#if this.paper.is_open_access}}
              <span class="paper-detail-page__badge -success">
                {{i18n "scholar.paper.metrics.open_access"}}
              </span>
            {{/if}}
          </div>

          <h1 class="paper-detail-page__title">{{this.paper.title}}</h1>

          <div class="paper-detail-page__authors">
            {{#if this.authors.length}}
              {{#each this.authors as |author|}}
                <span class="paper-detail-page__author">
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
                    >{{author.name}}</a>
                  {{else}}
                    {{author.name}}
                  {{/if}}

                  {{#if author.affiliations.length}}
                    <span class="paper-detail-page__author-affiliations">
                      {{author.affiliations}}
                    </span>
                  {{/if}}
                </span>
              {{/each}}
            {{else}}
              <span>{{i18n "scholar.paper.states.no_authors"}}</span>
            {{/if}}
          </div>

          <div class="paper-detail-page__summary-line">
            {{#if this.paper.venue}}
              <span>{{this.paper.venue}}</span>
            {{/if}}

            {{#if this.paper.year}}
              <span>{{this.paper.year}}</span>
            {{/if}}

            {{#if this.paper.publication_date}}
              <span>{{this.paper.publication_date}}</span>
            {{/if}}
          </div>
        </div>
      </section>

      <section class="paper-detail-page__layout">
        <main class="paper-detail-page__main">
          <article class="paper-detail-page__card">
            <h2>{{i18n "scholar.paper.sections.abstract"}}</h2>

            {{#if this.paper.abstract}}
              <p class="paper-detail-page__abstract">{{this.paper.abstract}}</p>
            {{else}}
              <p class="paper-detail-page__empty">
                {{i18n "scholar.paper.states.no_abstract"}}
              </p>
            {{/if}}
          </article>

          <article class="paper-detail-page__card">
            <h2>{{i18n "scholar.paper.sections.fields_of_study"}}</h2>

            {{#if this.fieldsOfStudy.length}}
              <div class="paper-detail-page__tags">
                {{#each this.fieldsOfStudy as |field|}}
                  <span class="paper-detail-page__tag">{{field}}</span>
                {{/each}}
              </div>
            {{else}}
              <p class="paper-detail-page__empty">
                {{i18n "scholar.paper.states.no_fields"}}
              </p>
            {{/if}}
          </article>
        </main>

        <aside class="paper-detail-page__sidebar">
          <article class="paper-detail-page__card">
            <h2>{{i18n "scholar.paper.sections.metrics"}}</h2>

            <dl class="paper-detail-page__stats">
              <div>
                <dt>{{i18n "scholar.paper.metrics.citations"}}</dt>
                <dd>{{number this.paper.citation_count}}</dd>
              </div>
              <div>
                <dt>{{i18n "scholar.paper.metrics.references"}}</dt>
                <dd>{{number this.paper.reference_count}}</dd>
              </div>
            </dl>
          </article>

          <article class="paper-detail-page__card">
            <h2>{{i18n "scholar.paper.sections.links"}}</h2>

            <dl class="paper-detail-page__meta">
              {{#if this.paper.venue}}
                <div>
                  <dt>{{i18n "scholar.paper.meta.venue"}}</dt>
                  <dd>{{this.paper.venue}}</dd>
                </div>
              {{/if}}

              {{#if this.paper.year}}
                <div>
                  <dt>{{i18n "scholar.paper.meta.year"}}</dt>
                  <dd>{{this.paper.year}}</dd>
                </div>
              {{/if}}

              {{#if this.paper.publication_date}}
                <div>
                  <dt>{{i18n "scholar.paper.meta.publication_date"}}</dt>
                  <dd>{{this.paper.publication_date}}</dd>
                </div>
              {{/if}}

              {{#if this.paper.doi}}
                <div>
                  <dt>{{i18n "scholar.paper.meta.doi"}}</dt>
                  <dd>
                    <a
                      href={{this.paper.doi_url}}
                      target="_blank"
                      rel="noopener noreferrer"
                    >{{this.paper.doi}}</a>
                  </dd>
                </div>
              {{/if}}

              {{#if this.paper.id}}
                <div>
                  <dt>{{i18n "scholar.paper.meta.paper_id"}}</dt>
                  <dd class="paper-detail-page__mono">{{this.paper.id}}</dd>
                </div>
              {{/if}}

              {{#if this.paper.url}}
                <div>
                  <dt>{{i18n "scholar.paper.links.source"}}</dt>
                  <dd>
                    <a
                      href={{this.paper.url}}
                      target="_blank"
                      rel="noopener noreferrer"
                    >{{i18n "scholar.paper.links.source"}}</a>
                  </dd>
                </div>
              {{/if}}

              {{#if this.paper.pdf_url}}
                <div>
                  <dt>{{i18n "scholar.paper.links.pdf"}}</dt>
                  <dd>
                    <a
                      href={{this.paper.pdf_url}}
                      target="_blank"
                      rel="noopener noreferrer"
                    >{{i18n "scholar.paper.links.pdf"}}</a>
                  </dd>
                </div>
              {{/if}}
            </dl>
          </article>
        </aside>
      </section>
      {{/if}}
    </div>
  </template>
}
