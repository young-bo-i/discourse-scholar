import Component from "@glimmer/component";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import avatar from "discourse/helpers/avatar";
import icon from "discourse/helpers/d-icon";
import DiscourseURL from "discourse/lib/url";
import { i18n } from "discourse-i18n";

export default class ScholarHeader extends Component {
  @service currentUser;
  @service router;

  get isHomeActive() {
    const url = this.router.currentURL;
    return url === "/scholar" || url === "/scholar/";
  }

  get isSearchActive() {
    return this.router.currentURL?.startsWith("/scholar/search");
  }

  @action
  goToForum() {
    DiscourseURL.routeTo("/");
  }

  @action
  goToHome() {
    DiscourseURL.routeTo("/scholar");
  }

  @action
  goToSearch() {
    DiscourseURL.routeTo("/scholar/search");
  }

  @action
  goToProfile() {
    if (this.currentUser) {
      DiscourseURL.routeTo(`/u/${this.currentUser.username}`);
    } else {
      DiscourseURL.routeTo("/login");
    }
  }

  <template>
    <header class="scholar-header">
      <div class="scholar-header__inner">
        <div class="scholar-header__left">
          <button
            type="button"
            class="scholar-header__forum-btn"
            title={{i18n "scholar.header.back_to_forum"}}
            {{on "click" this.goToForum}}
          >
            {{icon "comments"}}
          </button>

          <button
            type="button"
            class="scholar-header__brand"
            {{on "click" this.goToHome}}
          >
            {{icon "graduation-cap"}}
            <span class="scholar-header__brand-text">Scholar</span>
          </button>
        </div>

        <nav class="scholar-header__nav">
          <button
            type="button"
            class="scholar-header__nav-link {{if this.isHomeActive '-active'}}"
            {{on "click" this.goToHome}}
          >
            {{i18n "scholar.header.home"}}
          </button>
          <button
            type="button"
            class="scholar-header__nav-link {{if this.isSearchActive '-active'}}"
            {{on "click" this.goToSearch}}
          >
            {{i18n "scholar.header.search"}}
          </button>
        </nav>

        <div class="scholar-header__right">
          {{#if this.currentUser}}
            <button
              type="button"
              class="scholar-header__avatar"
              title={{this.currentUser.username}}
              {{on "click" this.goToProfile}}
            >
              {{avatar this.currentUser imageSize="small"}}
            </button>
          {{else}}
            <button
              type="button"
              class="scholar-header__login-btn"
              {{on "click" this.goToProfile}}
            >
              {{i18n "scholar.header.login"}}
            </button>
          {{/if}}
        </div>
      </div>
    </header>
  </template>
}
