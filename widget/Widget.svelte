<script>
  import './theme.css'
  import { onMount, setContext } from 'svelte'
  import axios from 'redaxios'
  import Comment from './components/Comment.svelte'
  import Reply from './components/Reply.svelte'
  import { t } from './i18n'

  export let attrs
  export let commentsResult

  let page = 1

  let loadingComments = true

  let message = ''

  let error

  let theme = attrs.theme || 'light'

  const api = axios.create({
    baseURL: attrs.host,
  })

  function setMessage(msg) {
    message = msg
  }

  $: {
    document.documentElement.style.setProperty('color-scheme', theme)
  }

  onMount(() => {

    function onMessage(e) {
      try {
        const msg = JSON.parse(e.data)
        if (msg.from === 'cusdis') {
          switch (msg.event) {
            case 'setTheme':
              {
                theme = msg.data
              }
              break
          }
        }
      } catch (e) {}
    }
    window.addEventListener('message', onMessage)

    return () => {
      window.removeEventListener('message', onMessage)
    }
  })

  setContext('api', api)
  setContext('attrs', attrs)
  setContext('refresh', getComments)
  setContext('setMessage', setMessage)

  async function getComments(p = 1) {
    loadingComments = true
    try {
      const res = await api.get(`/api/open/comments`, {
        headers: {
          'x-timezone-offset': -new Date().getTimezoneOffset(),
        },
        params: {
          page: p,
          appId: attrs.appId,
          pageId: attrs.pageId,
        },
      })
      commentsResult = res.data.data
    } catch (e) {
      error = e
    } finally {
      loadingComments = false
    }
  }

  function onClickPage(p) {
    page = p
    getComments(p)
  }

  onMount(() => {
    getComments()
  })

  $: hasComments = commentsResult && commentsResult.data && commentsResult.data.length > 0
  $: commentCount = commentsResult ? commentsResult.data.length : 0

</script>

{#if !error}
  <div class:dark={theme === 'dark'}>
    {#if message}
      <div class="p-2 mb-4 bg-blue-500 text-white cusdis-message">
        {message}
      </div>
    {/if}

    <!-- Anchor jump link: only shown when there are comments to scroll past -->
    {#if hasComments}
      <div class="mb-4 px-1">
        <a href="#cusdis-reply-form" class="cusdis-jump-link text-sm text-gray-400 dark:text-gray-500 underline underline-offset-2 hover:text-gray-600 dark:hover:text-gray-300">
          {t('jump_to_form')}
        </a>
      </div>
    {/if}

    <!-- Comment list -->
    <div class="px-1">
      {#if loadingComments}
        <div class="text-gray-400 dark:text-gray-400 text-sm">{t('loading')}...</div>
      {:else if !hasComments}
        <div class="text-center py-8 text-gray-400 dark:text-gray-500 text-sm cusdis-empty-state">
          {t('empty_state')}
        </div>
      {:else}
        <!-- Section divider: N comments -->
        <div class="flex items-center gap-3 mb-6">
          <div class="flex-1 h-px bg-gray-200 dark:bg-gray-700"></div>
          <span class="text-xs text-gray-400 dark:text-gray-500 font-medium tracking-wide">
            {commentCount} {commentCount === 1 ? 'comment' : 'comments'}
          </span>
          <div class="flex-1 h-px bg-gray-200 dark:bg-gray-700"></div>
        </div>

        {#each commentsResult.data as comment (comment.id)}
          <Comment {comment} firstFloor={true} />
        {/each}

        {#if commentsResult.pageCount > 1}
          <div class="mt-4">
            {#each Array(commentsResult.pageCount) as _, index}
              <button
                class="px-2 py-1 text-sm mr-2 dark:text-gray-200"
                class:underline={page === index + 1}
                on:click={(_) => onClickPage(index + 1)}>{index + 1}</button
              >
            {/each}
          </div>
        {/if}
      {/if}
    </div>

    <!-- Reply form (below comments) -->
    <div class="mt-8 px-1" id="cusdis-reply-form">
      <div class="text-sm font-semibold text-gray-600 dark:text-gray-300 mb-4">
        {t('leave_a_comment')}
      </div>
      <Reply />
    </div>

    <div class="my-6" />
  </div>
{/if}

<style>
  .cusdis-empty-state {
    animation: cusdis-fadein 300ms ease-out;
  }

  .cusdis-message {
    animation: cusdis-fadein 200ms ease-out;
  }

  @keyframes cusdis-fadein {
    from { opacity: 0; }
    to { opacity: 1; }
  }

  @media (prefers-reduced-motion: reduce) {
    .cusdis-empty-state,
    .cusdis-message {
      animation: none;
    }
  }
</style>
