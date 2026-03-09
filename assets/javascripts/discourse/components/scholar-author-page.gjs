import Component from "@glimmer/component";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import number from "discourse/helpers/number";
import DiscourseURL from "discourse/lib/url";
import ScholarSearchBox from "./scholar-search-box";
import { i18n } from "discourse-i18n";

export default class ScholarAuthorPage extends Component {
  get author() {
    return this.args.author || {};
  }

  get affiliations() {
    return this.author.affiliations || [];
  }

  get papers() {
    return this.author.papers || [];
  }

  get errorMessage() {
    return this.author.error_message || i18n("scholar.author.states.unavailable");
  }

  navigateTo(path) {
    DiscourseURL.routeTo(path);
  }

  <template>
    <div class="scholar-page scholar-author-page">
      <ScholarSearchBox />

      {{#if this.author.load_error}}
        <section class="scholar-page__layout">
          <article class="scholar-page__card">
            <h2>{{i18n "scholar.author.states.unavailable"}}</h2>
            <p class="scholar-page__empty">{{this.errorMessage}}</p>
          </article>
        </section>
      {{else}}
        <section class="scholar-page__hero">
          <div class="scholar-page__hero-content">
            <h1 class="scholar-page__title">{{this.author.name}}</h1>

            {{#if this.affiliations.length}}
              <div class="scholar-page__tags">
                {{#each this.affiliations as |affiliation|}}
                  <span class="scholar-page__tag">{{affiliation}}</span>
                {{/each}}
              </div>
            {{/if}}
          </div>
        </section>

        <section class="scholar-page__layout">
          <main class="scholar-page__main">
            <article class="scholar-page__card">
              <h2>{{i18n "scholar.author.sections.affiliations"}}</h2>
              {{#if this.affiliations.length}}
                <ul class="scholar-page__list">
                  {{#each this.affiliations as |affiliation|}}
                    <li>{{affiliation}}</li>
                  {{/each}}
                </ul>
              {{else}}
                <p class="scholar-page__empty">
                  {{i18n "scholar.author.states.no_affiliations"}}
                </p>
              {{/if}}
            </article>

            <article class="scholar-page__card">
              <h2>{{i18n "scholar.author.sections.papers"}}</h2>
              {{#if this.papers.length}}
                <div class="scholar-page__result-list">
                  {{#each this.papers as |paper|}}
                    <button
                      type="button"
                      class="scholar-page__result"
                      {{on "click" (fn this.navigateTo paper.path)}}
                    >
                      <span class="scholar-page__result-title">{{paper.title}}</span>
                      <span class="scholar-page__result-meta">
                        {{paper.year}}
                        {{#if paper.venue}}
                          ·
                          {{paper.venue}}
                        {{/if}}
                        {{#if paper.citation_count}}
                          ·
                          {{number paper.citation_count}}
                          {{i18n "scholar.author.metrics.citations"}}
                        {{/if}}
                      </span>
                    </button>
                  {{/each}}
                </div>
              {{else}}
                <p class="scholar-page__empty">
                  {{i18n "scholar.author.states.no_papers"}}
                </p>
              {{/if}}
            </article>
          </main>

          <aside class="scholar-page__sidebar">
            <article class="scholar-page__card">
              <h2>{{i18n "scholar.author.sections.metrics"}}</h2>
              <dl class="scholar-page__stats">
                <div>
                  <dt>{{i18n "scholar.author.metrics.papers"}}</dt>
                  <dd>{{number this.author.paper_count}}</dd>
                </div>
                <div>
                  <dt>{{i18n "scholar.author.metrics.citations"}}</dt>
                  <dd>{{number this.author.citation_count}}</dd>
                </div>
                <div>
                  <dt>{{i18n "scholar.author.metrics.h_index"}}</dt>
                  <dd>{{number this.author.h_index}}</dd>
                </div>
              </dl>
            </article>
          </aside>
        </section>
      {{/if}}
    </div>
  </template>
}
