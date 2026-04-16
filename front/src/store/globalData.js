import { defineStore } from 'pinia';

export const useGlobalDataStore = defineStore('globalData', {
    state: () => ({
        userId: '',
        token:'',
        breadcrumbs: [] // { title, path, query }
  }),
  actions: {
    updateUserId(value) {
      this.userId = value;
      },
      updateToken(value) {
      this.token = value;
    },
    pushCrumb(crumb) {
      const key = crumb.path + JSON.stringify(crumb.query||{})
      const exists = this.breadcrumbs.find(c => c.path + JSON.stringify(c.query||{}) === key)
      if (!exists) this.breadcrumbs.push(crumb)
    },
    popCrumb() {
      if (this.breadcrumbs.length > 0) this.breadcrumbs.pop()
    },
    removeCrumb(index) {
      this.breadcrumbs.splice(index, 1)
    }
  },
});