import Component from "@glimmer/component";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import didInsert from "@ember/render-modifiers/modifiers/did-insert";
import didUpdate from "@ember/render-modifiers/modifiers/did-update";
import { tracked } from "@glimmer/tracking";
import { ajax } from "discourse/lib/ajax";
import DiscourseURL from "discourse/lib/url";
import { i18n } from "discourse-i18n";

const MIN_QUERY_LENGTH = 2;
const DEBOUNCE_MS = 200;

export default class ScholarSearchBox extends Component {
  @tracked query = null;
  @tracked suggestions = [];
  @tracked loading = false;

  requestId = 0;
  debounceTimer = null;
  searchPromise = null;

  get hasSuggestions() {
    return this.suggestions.length > 0;
  }

  get currentQuery() {
    return this.query ?? this.args.initialQuery ?? "";
  }

  willDestroy() {
    super.willDestroy(...arguments);
    clearTimeout(this.debounceTimer);
    this.searchPromise?.abort();
    this.searchPromise = null;
  }

  @action
  syncInitialQuery() {
    this.query = this.args.initialQuery ?? "";
  }

  suggestionTypeLabel(type) {
    return i18n(`scholar.search.types.${type}`);
  }

  @action
  handleInput(event) {
    this.query = event.target.value;
    clearTimeout(this.debounceTimer);
    this.searchPromise?.abort();
    this.searchPromise = null;

    if (this.currentQuery.trim().length < MIN_QUERY_LENGTH) {
      this.loading = false;
      this.suggestions = [];
      return;
    }

    this.debounceTimer = setTimeout(() => this.fetchSuggestions(), DEBOUNCE_MS);
  }

  @action
  handleSubmit(event) {
    event.preventDefault();

    const query = this.currentQuery.trim();
    if (!query) {
      return;
    }

    this.searchPromise?.abort();
    this.searchPromise = null;
    this.suggestions = [];
    DiscourseURL.routeTo(`/scholar/search?q=${encodeURIComponent(query)}`);
  }

  @action
  selectSuggestion(path) {
    this.searchPromise?.abort();
    this.searchPromise = null;
    this.suggestions = [];
    DiscourseURL.routeTo(path);
  }

  async fetchSuggestions() {
    const query = this.currentQuery.trim();
    if (query.length < MIN_QUERY_LENGTH) {
      return;
    }

    const requestId = ++this.requestId;
    this.loading = true;

    try {
      this.searchPromise = ajax(
        `/scholar/autocomplete.json?q=${encodeURIComponent(query)}`
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
          {{did-insert this.syncInitialQuery}}
          {{did-update this.syncInitialQuery @initialQuery}}
          {{on "input" this.handleInput}}
        />
      </form>

      {{#if this.hasSuggestions}}
        <div class="scholar-search-box__suggestions">
          {{#each this.suggestions as |item|}}
            <button
              type="button"
              class="scholar-search-box__suggestion"
              {{on "click" (fn this.selectSuggestion item.path)}}
            >
              <span class="scholar-search-box__suggestion-label">
                {{item.label}}
              </span>
              <span class="scholar-search-box__suggestion-meta">
                {{this.suggestionTypeLabel item.type}}
                {{#if item.subtext}}
                  ·
                  {{item.subtext}}
                {{/if}}
              </span>
            </button>
          {{/each}}
        </div>
      {{else if this.loading}}
        <div class="scholar-search-box__suggestions -loading">
          {{i18n "scholar.search.loading"}}
        </div>
      {{/if}}
    </section>
  </template>
}
