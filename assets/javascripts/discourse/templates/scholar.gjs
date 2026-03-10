import ScholarHeader from "../components/scholar-header";

export default <template>
  <ScholarHeader />
  <div class="scholar-body">
    {{outlet}}
  </div>
</template>
