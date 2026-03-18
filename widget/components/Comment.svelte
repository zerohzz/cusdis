<script>
  import { getContext } from 'svelte'
  import { t } from '../i18n'

  import Reply from './Reply.svelte'
  export let comment
  export let showReplyForm = false
  export let isChild = false

  const { showIndicator } = getContext('attrs')

  // relative timestamp
  function timeAgo(dateStr) {
    const d = new Date(dateStr)
    const now = new Date()
    const diff = Math.floor((now - d) / 1000)
    if (diff < 60) return 'just now'
    if (diff < 3600) return `${Math.floor(diff / 60)}m ago`
    if (diff < 86400) return `${Math.floor(diff / 3600)}h ago`
    if (diff < 2592000) return `${Math.floor(diff / 86400)}d ago`
    return d.toLocaleDateString()
  }

  $: isAuthor = !!comment.moderatorId
</script>

<!-- card: author gets teal tint, children get accent left border -->
<div
  class="my-3 p-4 rounded-lg border border-gray-100 dark:border-gray-700"
  class:cusdis-child={isChild}
  class:cusdis-author-card={isAuthor}
  class:cusdis-regular-card={!isAuthor}
  class:cusdis-indicator={showIndicator}
>
  <div class="flex items-center gap-2">
    <div class="font-medium dark:text-gray-100">
      {comment.moderator && comment.moderator.displayName ? comment.moderator.displayName : comment.by_nickname}
    </div>

    {#if isAuthor}
      <!-- Author badge: teal-green, distinct from accent -->
      <div class="cusdis-author-badge">
        {t('author_badge')}
      </div>
    {/if}
  </div>

  <!-- accessible timestamp -->
  <time
    datetime={comment.createdAt}
    title={comment.parsedCreatedAt}
    class="block text-gray-500 text-sm dark:text-gray-400 mt-0.5"
  >
    {timeAgo(comment.createdAt)}
  </time>

  <div class="text-gray-500 my-2 dark:text-gray-200">
    {@html comment.parsedContent}
  </div>

  {#if comment.replies.data.length > 0}
    {#each comment.replies.data as child (child.id)}
      <svelte:self isChild={true} comment={child} />
    {/each}
  {/if}

  <div class="mt-2">
    <button
      class="cusdis-reply-btn text-sm text-gray-500 dark:text-gray-400"
      type="button"
      on:click={(_) => {
        showReplyForm = !showReplyForm
      }}>↩ {t('reply_btn')}</button
    >
  </div>

  {#if showReplyForm}
    <div class="mt-4 cusdis-reply-form-reveal">
      <Reply
        parentId={comment.id}
        onSuccess={() => {
          showReplyForm = false
        }}
      />
    </div>
  {/if}
</div>

<style>
  /* Regular comment card */
  .cusdis-regular-card {
    background-color: #f9f8f6;
  }
  :global(.dark) .cusdis-regular-card {
    background-color: #1f1f1d;
  }

  /* Author comment card: subtle teal tint */
  .cusdis-author-card {
    background-color: rgba(29, 106, 74, 0.05);
  }
  :global(.dark) .cusdis-author-card {
    background-color: rgba(29, 106, 74, 0.10);
  }

  /* Author badge */
  .cusdis-author-badge {
    display: inline-flex;
    align-items: center;
    padding: 1px 8px;
    border-radius: 9999px;
    font-size: 0.65rem;
    font-weight: 600;
    letter-spacing: 0.05em;
    background-color: #1d6a4a;
    color: white;
  }

  /* Nested reply: accent left border */
  .cusdis-child {
    border-left: 3px solid #AF8F6F !important;
    margin-left: 1rem;
  }

  /* Reply button: ghost style */
  .cusdis-reply-btn {
    cursor: pointer;
    padding: 2px 10px;
    border-radius: 4px;
    border: 1px solid currentColor;
    background: transparent;
    transition: background-color 150ms ease-out, color 150ms ease-out;
  }
  .cusdis-reply-btn:hover {
    background-color: rgba(175, 143, 111, 0.10);
    color: #AF8F6F;
    border-color: #AF8F6F;
  }

  /* Reply form slide-in */
  .cusdis-reply-form-reveal {
    animation: cusdis-reveal 200ms cubic-bezier(0.25, 1, 0.5, 1);
  }

  @keyframes cusdis-reveal {
    from {
      opacity: 0;
      transform: translateY(4px);
    }
    to {
      opacity: 1;
      transform: translateY(0);
    }
  }

  @media (prefers-reduced-motion: reduce) {
    .cusdis-reply-form-reveal {
      animation: none;
    }
    .cusdis-reply-btn {
      transition: none;
    }
  }
</style>
