// Serves the dotfiles bootstrap at https://dotfiles.msanchez.dev/install (and /)
// so it can be piped straight to a shell:
//
//   curl https://dotfiles.msanchez.dev/install | bash
//
// It proxies the LATEST bootstrap.sh from the GitHub repo and returns it with a
// 200 (not a redirect — so no `curl -L` needed). Nothing to redeploy when the
// script changes; just edit bootstrap.sh in the repo.
const BOOTSTRAP_URL =
  'https://raw.githubusercontent.com/msanchezdev/.dotfiles/main/bootstrap.sh';

export default {
  async fetch(request) {
    const { pathname } = new URL(request.url);
    if (pathname !== '/' && pathname !== '/install') {
      return new Response('Not found\n', { status: 404 });
    }

    // Edge-cache the upstream fetch briefly so a burst of installs doesn't hammer
    // GitHub, while staying fresh within a few minutes of a push.
    const upstream = await fetch(BOOTSTRAP_URL, {
      cf: { cacheTtl: 300, cacheEverything: true },
    });
    if (!upstream.ok) {
      return new Response(`Failed to fetch bootstrap (${upstream.status})\n`, {
        status: 502,
      });
    }

    return new Response(upstream.body, {
      status: 200,
      headers: {
        'content-type': 'text/x-shellscript; charset=utf-8',
        'cache-control': 'public, max-age=300',
      },
    });
  },
};
