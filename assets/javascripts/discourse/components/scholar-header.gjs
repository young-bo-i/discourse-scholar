import Component from "@glimmer/component";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import avatar from "discourse/helpers/avatar";
import icon from "discourse/helpers/d-icon";
import getURL from "discourse/lib/get-url";
import DiscourseURL from "discourse/lib/url";
import { i18n } from "discourse-i18n";
import ScholarSearchBox from "./scholar-search-box";

export default class ScholarHeader extends Component {
  @service currentUser;
  @service router;
  @service siteSettings;

  get forumLogoUrl() {
    return getURL(
      this.siteSettings.site_logo_small_url ||
        this.siteSettings.site_logo_url ||
        ""
    );
  }

  get isHomePage() {
    const url = this.router.currentURL;
    return url === "/scholar" || url === "/scholar/";
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
            {{#if this.forumLogoUrl}}
              <img
                src={{this.forumLogoUrl}}
                alt={{this.siteSettings.title}}
                class="scholar-header__forum-logo"
              />
            {{else}}
              {{icon "comments"}}
            {{/if}}
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

        {{#unless this.isHomePage}}
          <div class="scholar-header__search">
            <ScholarSearchBox />
          </div>
        {{/unless}}

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
