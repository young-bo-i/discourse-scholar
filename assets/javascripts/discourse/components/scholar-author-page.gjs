import Component from "@glimmer/component";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import icon from "discourse/helpers/d-icon";
import number from "discourse/helpers/number";
import DiscourseURL from "discourse/lib/url";
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
    return (
      this.author.error_message || i18n("scholar.author.states.unavailable")
    );
  }

  navigateTo(path) {
    DiscourseURL.routeTo(path);
  }

  <template>
    <div class="scholar-page scholar-author-page">
      {{#if this.author.load_error}}
        <div class="scholar-author-page__error-card">
          <h2>{{i18n "scholar.author.states.unavailable"}}</h2>
          <p>{{this.errorMessage}}</p>
        </div>
      {{else}}
        <div class="scholar-author-page__container">
          <aside class="scholar-author-page__sidebar">
            <div class="scholar-author-page__profile-card">
              <div class="scholar-author-page__avatar">
                {{icon "user"}}
              </div>
              <h1 class="scholar-author-page__name">{{this.author.name}}</h1>

              {{#if this.affiliations.length}}
                <div class="scholar-author-page__affiliations">
                  {{#each this.affiliations as |affiliation|}}
                    <span>{{affiliation}}</span>
                  {{/each}}
                </div>
              {{/if}}

              <dl class="scholar-author-page__stats">
                <div class="scholar-author-page__stat-row">
                  <dt>{{i18n "scholar.author.metrics.papers"}}</dt>
                  <dd>{{number this.author.paper_count}}</dd>
                </div>
                <div class="scholar-author-page__stat-row">
                  <dt>{{i18n "scholar.author.metrics.citations"}}</dt>
                  <dd>{{number this.author.citation_count}}</dd>
                </div>
                <div class="scholar-author-page__stat-row">
                  <dt>{{i18n "scholar.author.metrics.h_index"}}</dt>
                  <dd>{{number this.author.h_index}}</dd>
                </div>
              </dl>
            </div>
          </aside>

          <main class="scholar-author-page__main">
            <div class="scholar-author-page__section-header">
              <h2>{{i18n "scholar.author.sections.papers"}}</h2>
            </div>

            {{#if this.papers.length}}
              <div class="scholar-author-page__paper-list">
                {{#each this.papers as |paper|}}
                  <article class="scholar-result-card">
                    <button
                      type="button"
                      class="scholar-result-card__link"
                      {{on "click" (fn this.navigateTo paper.path)}}
                    >
                      <h3 class="scholar-result-card__title">{{paper.title}}</h3>
                    </button>
                    <div class="scholar-result-card__meta">
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
              <p
                class="scholar-author-page__empty"
              >{{i18n "scholar.author.states.no_papers"}}</p>
            {{/if}}
          </main>
        </div>
      {{/if}}
    </div>
  </template>
}
