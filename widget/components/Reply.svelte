<script>
  import { getContext } from 'svelte'
  import { t } from '../i18n'
  export let parentId

  // form data
  let content = ''
  let nickname = ''
  let email = ''

  let loading = false
  let error = ''

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
      error = ''
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
    } catch (e) {
      error = t('posting_error')
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

  $: charCount = content.length
  $: charWarning = charCount > 800

</script>

<div class="grid grid-cols-1 gap-4">
  <!-- name + email row -->
  <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
    <div class="px-1">
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
    <textarea
      name="reply_content"
      class="w-full p-2 border border-gray-200 h-24 bg-transparent dark:text-gray-100 dark:outline-none"
      title={t('reply_placeholder')}
      placeholder={t('reply_placeholder')}
      bind:value={content}
    />
    <!-- char count + hint -->
    <div class="flex justify-between items-center mt-1 px-0.5">
      <span class="text-xs text-gray-400 dark:text-gray-500">{t('char_hint')}</span>
      <span class="text-xs cusdis-char-count" class:cusdis-char-warn={charWarning}>
        {charCount} chars
      </span>
    </div>
  </div>

  <div class="px-1">
    <button
      class="text-sm font-bold px-5 py-2 rounded-md cusdis-btn flex items-center gap-2"
      class:cusdis-disabled={loading}
      style="background-color: #AF8F6F; color: white; border: none;"
      disabled={loading}
      on:click={addComment}
    >
      {#if loading}
        <span class="cusdis-spinner" aria-hidden="true"></span>
      {/if}
      {loading ? t('sending') : t('post_comment')}
    </button>

    {#if error}
      <div class="cusdis-error mt-2 text-sm" style="color: #dc2626;">
        {error}
      </div>
    {/if}
  </div>
</div>

<style>
  /* focus ring on inputs + textarea */
  input:focus,
  textarea:focus {
    outline: 2px solid #AF8F6F;
    outline-offset: 1px;
    border-color: #AF8F6F;
  }

  /* no native resize handle */
  textarea {
    resize: none;
  }

  /* char counter */
  .cusdis-char-count {
    color: #9ca3af;
    transition: color 200ms ease-out;
  }
  .cusdis-char-warn {
    color: #d97706;
  }

  /* button */
  .cusdis-btn {
    cursor: pointer;
    transition: filter 0.15s ease, transform 0.15s ease;
  }
  .cusdis-btn:hover:not(.cusdis-disabled) {
    filter: brightness(1.1);
    transform: translateY(-1px);
  }
  .cusdis-btn:active:not(.cusdis-disabled) {
    transform: translateY(0);
  }
  .cusdis-btn.cusdis-disabled {
    opacity: 0.6;
    cursor: not-allowed;
    transform: none;
    filter: none;
  }

  /* inline spinner */
  .cusdis-spinner {
    display: inline-block;
    width: 12px;
    height: 12px;
    border: 2px solid rgba(255, 255, 255, 0.4);
    border-top-color: white;
    border-radius: 50%;
    animation: cusdis-spin 0.6s linear infinite;
    flex-shrink: 0;
  }

  @keyframes cusdis-spin {
    to { transform: rotate(360deg); }
  }

  /* error message */
  .cusdis-error {
    animation: cusdis-fadein 150ms ease-out;
  }

  @keyframes cusdis-fadein {
    from { opacity: 0; }
    to { opacity: 1; }
  }

  @media (prefers-reduced-motion: reduce) {
    .cusdis-btn {
      transition: none;
    }
    .cusdis-spinner {
      animation: none;
      border-top-color: rgba(255, 255, 255, 0.8);
    }
    .cusdis-error {
      animation: none;
    }
    .cusdis-char-count {
      transition: none;
    }
  }
</style>
