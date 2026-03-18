<script>
  import { getContext } from 'svelte'
  import { t } from '../i18n'
  export let parentId

  // form data
  let content = ''
  let nickname = ''
  let email = ''

  let loading = false

  export let onSuccess

  const api = getContext('api')
  const setMessage = getContext('setMessage')
  const { appId, pageId, pageUrl, pageTitle } = getContext('attrs')
  const refresh = getContext('refresh')

  async function addComment() {
    if (!content) {
      alert(t('content_is_required'))
      return
    }

    if (!nickname) {
      alert(t('nickname_is_required'))
      return
    }

    try {
      loading = true
      await api.post('/api/open/comments', {
        appId,
        pageId,
        content,
        nickname,
        email,
        parentId,
        pageUrl,
        pageTitle,
      })
      await refresh()
      teardown()
      setMessage(t('comment_has_been_sent'))
    } finally {
      loading = false
    }
  }

  function teardown() {
    content = ''
    nickname = ''
    email = ''
    onSuccess && onSuccess()
  }

</script>

<div class="grid grid-cols-1 gap-4">
  <!-- #10: stack on mobile, 2-col on sm+ -->
  <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
    <div class="px-1">
      <!-- #3: bolder labels -->
      <label class="mb-2 block text-sm font-medium dark:text-gray-200" for="nickname">{t('nickname')}</label>
      <input
        name="nickname"
        class="w-full p-2 border border-gray-200 bg-transparent dark:text-gray-100 dark:outline-none"
        type="text"
        title={t('nickname')}
        bind:value={nickname}
      />
    </div>
    <div class="px-1">
      <label class="mb-2 block text-sm font-medium dark:text-gray-200" for="email">{t('email')}</label>
      <input
        name="email"
        class="w-full p-2 border border-gray-200 bg-transparent dark:text-gray-100 dark:outline-none"
        type="email"
        title={t('email')}
        bind:value={email}
      />
    </div>
  </div>

  <div class="px-1">
    <label class="mb-2 block text-sm font-medium dark:text-gray-200" for="reply_content">{t('reply_placeholder')}</label>
    <!-- #4: add placeholder attribute -->
    <textarea
      name="reply_content"
      class="w-full p-2 border border-gray-200 h-24 bg-transparent dark:text-gray-100 dark:outline-none"
      title={t('reply_placeholder')}
      placeholder={t('reply_placeholder')}
      bind:value={content}
    />
  </div>

  <div class="px-1">
    <!-- #1: accent-coloured filled button -->
    <button
      class="text-sm font-bold px-5 py-2 rounded-md cusdis-btn"
      class:cusdis-disabled={loading}
      style="background-color: #AF8F6F; color: white; border: none;"
      on:click={addComment}>{loading ? t('sending') : t('post_comment')}</button
    >
  </div>
</div>

<style>
  /* #2: focus ring on inputs + textarea */
  input:focus,
  textarea:focus {
    outline: 2px solid #AF8F6F;
    outline-offset: 1px;
    border-color: #AF8F6F;
  }

  /* #1: button hover/active states */
  .cusdis-btn {
    cursor: pointer;
    transition: filter 0.15s ease, transform 0.15s ease;
  }
  .cusdis-btn:hover {
    filter: brightness(1.1);
    transform: translateY(-1px);
  }
  .cusdis-btn:active {
    transform: translateY(0);
  }
  .cusdis-btn.cusdis-disabled {
    opacity: 0.6;
    cursor: not-allowed;
    transform: none;
    filter: none;
  }
</style>
