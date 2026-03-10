import Component from "@glimmer/component";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import icon from "discourse/helpers/d-icon";
import DiscourseURL from "discourse/lib/url";
import { i18n } from "discourse-i18n";
import ScholarSearchBox from "./scholar-search-box";

export default class ScholarHomePage extends Component {
  @action
  goToSearch() {
    DiscourseURL.routeTo("/scholar/search");
  }

  <template>
    <div class="scholar-page scholar-home-page">
      <section class="scholar-home-page__hero">
        <h1 class="scholar-home-page__title">
          {{icon "graduation-cap"}}
          {{i18n "scholar.home.title"}}
        </h1>
        <p class="scholar-home-page__subtitle">
          {{i18n "scholar.home.subtitle"}}
        </p>
        <div class="scholar-home-page__search">
          <ScholarSearchBox />
        </div>
      </section>

      <section class="scholar-home-page__cards">
        <button
          type="button"
          class="scholar-home-page__card"
          {{on "click" this.goToSearch}}
        >
          <span class="scholar-home-page__card-icon">{{icon "magnifying-glass"}}</span>
          <span class="scholar-home-page__card-title">{{i18n "scholar.home.search_papers"}}</span>
          <span class="scholar-home-page__card-desc">{{i18n "scholar.home.search_papers_desc"}}</span>
        </button>

        <button
          type="button"
          class="scholar-home-page__card"
          {{on "click" this.goToSearch}}
        >
          <span class="scholar-home-page__card-icon">{{icon "users"}}</span>
          <span class="scholar-home-page__card-title">{{i18n "scholar.home.search_authors"}}</span>
          <span class="scholar-home-page__card-desc">{{i18n "scholar.home.search_authors_desc"}}</span>
        </button>
      </section>
    </div>
  </template>
}
