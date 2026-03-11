import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { concat, fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import didInsert from "@ember/render-modifiers/modifiers/did-insert";
import didUpdate from "@ember/render-modifiers/modifiers/did-update";
import icon from "discourse/helpers/d-icon";
import { ajax } from "discourse/lib/ajax";
import DiscourseURL from "discourse/lib/url";
import { i18n } from "discourse-i18n";

const MIN_QUERY_LENGTH = 3;
const MAX_QUERY_LENGTH = 500;
const DEBOUNCE_MS = 200;

export default class ScholarSearchBox extends Component {
  @tracked query = null;
  @tracked suggestions = [];
  @tracked loading = false;

  requestId = 0;
  debounceTimer = null;
  searchPromise = null;

  willDestroy() {
    super.willDestroy(...arguments);
    clearTimeout(this.debounceTimer);
    this.searchPromise?.abort();
    this.searchPromise = null;
  }

  get hasSuggestions() {
    return this.suggestions.length > 0;
  }

  get authorSuggestions() {
    return this.suggestions.filter((item) => item.type === "author");
  }

  get paperSuggestions() {
    return this.suggestions.filter((item) => item.type === "paper");
  }

  get currentQuery() {
    return this.query ?? this.args.initialQuery ?? "";
  }

  

  @action
  syncInitialQuery() {
    this.query = this.args.initialQuery ?? "";
  }

  @action
  handleInput(event) {
    let val = event.target.value;
    if (val.length > MAX_QUERY_LENGTH) {
      val = val.slice(0, MAX_QUERY_LENGTH);
      event.target.value = val;
    }
    this.query = val;

    clearTimeout(this.debounceTimer);
    this.searchPromise?.abort();
    this.searchPromise = null;

    const trimmed = this.currentQuery.trim();
    if (trimmed.length < MIN_QUERY_LENGTH || trimmed.length > MAX_QUERY_LENGTH) {
      this.loading = false;
      this.suggestions = [];
      return;
    }

    this.debounceTimer = setTimeout(() => this.fetchSuggestions(), DEBOUNCE_MS);
  }

  get currentSource() {
    return this.args.source || "stc";
  }

  @action
  handleSubmit(event) {
    event.preventDefault();

    const query = this.currentQuery.trim();
    if (query.length < MIN_QUERY_LENGTH || query.length > MAX_QUERY_LENGTH) {
      return;
    }

    this.dismissSuggestions();
    DiscourseURL.routeTo(
      `/scholar/search?q=${encodeURIComponent(query)}&source=${this.currentSource}`
    );
  }

  @action
  selectSuggestion(path) {
    this.dismissSuggestions();
    DiscourseURL.routeTo(path);
  }

  @action
  handleBlur() {
    setTimeout(() => {
      this.suggestions = [];
    }, 150);
  }

  dismissSuggestions() {
    clearTimeout(this.debounceTimer);
    this.searchPromise?.abort();
    this.searchPromise = null;
    this.suggestions = [];
  }

  async fetchSuggestions() {
    const query = this.currentQuery.trim();
    if (query.length < MIN_QUERY_LENGTH || query.length > MAX_QUERY_LENGTH) {
      return;
    }

    const requestId = ++this.requestId;
    this.loading = true;

    try {
      this.searchPromise = ajax(
        `/scholar/autocomplete.json?q=${encodeURIComponent(query)}&source=${this.currentSource}`
      );
      const response = await this.searchPromise;

      if (requestId !== this.requestId) {
        return;
      }

      this.suggestions = response.items || [];
    } catch {
      if (requestId === this.requestId) {
        this.suggestions = [];
      }
    } finally {
      if (requestId === this.requestId) {
        this.loading = false;
        this.searchPromise = null;
      }
    }
  }

  <template>
    <section class="scholar-search-box">
      <form class="scholar-search-box__form" {{on "submit" this.handleSubmit}}>
        <input
          class="scholar-search-box__input"
          type="search"
          value={{this.currentQuery}}
          placeholder={{i18n "scholar.search.placeholder"}}
          autocomplete="off"
          minlength="3"
          maxlength="500"
          {{didInsert this.syncInitialQuery}}
          {{didUpdate this.syncInitialQuery @initialQuery}}
          {{on "input" this.handleInput}}
          {{on "blur" this.handleBlur}}
        />
        <button type="submit" class="scholar-search-box__submit">
          {{icon "magnifying-glass"}}
        </button>
      </form>

      {{#if this.hasSuggestions}}
        <div class="scholar-search-box__suggestions">
          {{#if this.authorSuggestions.length}}
            <div class="scholar-search-box__group">
              <div class="scholar-search-box__group-header">
                {{i18n "scholar.search.suggestions.matching_authors"}}
              </div>
              {{#each this.authorSuggestions as |item|}}
                <button
                  type="button"
                  class="scholar-search-box__suggestion -author"
                  {{on "click" (fn this.selectSuggestion item.path)}}
                >
                  {{icon "user"}}
                  <span class="scholar-search-box__suggestion-content">
                    <span class="scholar-search-box__suggestion-label">
                      {{item.label}}
                    </span>
                    {{#if item.subtext}}
                      <span class="scholar-search-box__suggestion-meta">
                        {{item.subtext}}
                      </span>
                    {{/if}}
                  </span>
                </button>
              {{/each}}
            </div>
          {{/if}}

          {{#if this.paperSuggestions.length}}
            <div class="scholar-search-box__group">
              <div class="scholar-search-box__group-header">
                {{i18n "scholar.search.suggestions.matching_papers"}}
              </div>
              {{#each this.paperSuggestions as |item|}}
                <button
                  type="button"
                  class="scholar-search-box__suggestion -paper"
                  {{on "click" (fn this.selectSuggestion item.path)}}
                >
                  {{icon "file-lines"}}
                  <span class="scholar-search-box__suggestion-content">
                    <span class="scholar-search-box__suggestion-label">
                      {{item.label}}
                    </span>
                    {{#if item.subtext}}
                      <span class="scholar-search-box__suggestion-meta">
                        {{item.subtext}}
                      </span>
                    {{/if}}
                  </span>
                </button>
              {{/each}}
            </div>
          {{/if}}

          <button
            type="button"
            class="scholar-search-box__see-all"
            {{on "click" this.handleSubmit}}
          >
            {{i18n "scholar.search.suggestions.see_all" query=this.currentQuery}}
          </button>
        </div>
      {{/if}}
    </section>
  </template>
}
