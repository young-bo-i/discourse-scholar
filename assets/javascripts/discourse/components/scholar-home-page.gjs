import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
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
      <section class="scholar-home-page__hero">
        <h1 class="scholar-home-page__title">
          <ScholarLogo />
          <span class="scholar-home-page__title-text">
            {{i18n "scholar.home.title"}}
          </span>
        </h1>
        <p class="scholar-home-page__subtitle">
          {{i18n "scholar.home.subtitle"}}
        </p>

        <div class="scholar-home-page__source-tabs">
          <button
            type="button"
            class="scholar-home-page__source-tab
              {{if this.isSourceStc '-active'}}"
            {{on "click" (fn this.switchSource "stc")}}
          >{{i18n "scholar.search.sources.stc"}}</button>
          <button
            type="button"
            class="scholar-home-page__source-tab
              {{if this.isSourceOlx '-active'}}"
            {{on "click" (fn this.switchSource "olx")}}
          >{{i18n "scholar.search.sources.olx"}}</button>
        </div>

        <div class="scholar-home-page__search">
          <ScholarSearchBox @source={{this.source}} />
        </div>
      </section>
    </div>
  </template>
}
