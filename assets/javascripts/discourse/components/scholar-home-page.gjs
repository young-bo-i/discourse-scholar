import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import icon from "discourse/helpers/d-icon";
import { i18n } from "discourse-i18n";
import ScholarLogo from "./scholar-logo";
import ScholarSearchBox from "./scholar-search-box";

export default class ScholarHomePage extends Component {
  @tracked source = "stc";

  get isSourceStc() {
    return this.source === "stc";
  }

  get isSourceOlx() {
    return this.source === "olx";
  }

  @action
  switchSource(src) {
    this.source = src;
  }

  <template>
    <div class="scholar-page scholar-home-page">
      <div class="scholar-home-page__bg-glow"></div>

      <section class="scholar-home-page__hero">
        <div class="scholar-home-page__brand">
          <ScholarLogo />
          <h1 class="scholar-home-page__title">
            {{i18n "scholar.home.title"}}
          </h1>
        </div>
        <p class="scholar-home-page__subtitle">
          {{i18n "scholar.home.subtitle"}}
        </p>

        <div class="scholar-home-page__source-picker">
          <button
            type="button"
            class="scholar-home-page__source-card
              {{if this.isSourceStc '-active'}}"
            {{on "click" (fn this.switchSource "stc")}}
          >
            <span class="scholar-home-page__source-icon">{{icon "book-open-reader"}}</span>
            <span class="scholar-home-page__source-name">{{i18n "scholar.search.sources.stc"}}</span>
            <span class="scholar-home-page__source-desc">{{i18n "scholar.home.source_desc_stc"}}</span>
          </button>
          <button
            type="button"
            class="scholar-home-page__source-card
              {{if this.isSourceOlx '-active'}}"
            {{on "click" (fn this.switchSource "olx")}}
          >
            <span class="scholar-home-page__source-icon">{{icon "globe"}}</span>
            <span class="scholar-home-page__source-name">{{i18n "scholar.search.sources.olx"}}</span>
            <span class="scholar-home-page__source-desc">{{i18n "scholar.home.source_desc_olx"}}</span>
          </button>
        </div>

        <div class="scholar-home-page__search">
          <ScholarSearchBox @source={{this.source}} />
        </div>

        <div class="scholar-home-page__hints">
          <span class="scholar-home-page__hint">{{icon "lightbulb"}} {{i18n "scholar.home.hint"}}</span>
        </div>
      </section>
    </div>
  </template>
}
