import { test, expect } from '@playwright/test';
import type { Page } from '@playwright/test';

async function enableAccessibility(page: Page) {
  const enableButton = page.getByRole('button', { name: 'Enable accessibility' });
  if (await enableButton.count()) {
    await enableButton.press('Enter');
    await page.waitForTimeout(250);
  }
}

test.describe('Smoke', () => {

  test('app renders without fatal error', async ({ page }) => {
    const errors: string[] = [];
    page.on('pageerror', err => errors.push(err.message));
    page.on('console', msg => {
      if (msg.type() === 'error') errors.push(msg.text());
    });

    await page.goto('/');
    // Flutter web bootstraps async — wait for hydration
    await page.waitForTimeout(6000);

    // Something rendered (not a blank page)
    const bodyHtml = await page.locator('body').innerHTML();
    expect(bodyHtml.length, 'Body should contain Flutter output').toBeGreaterThan(200);

    // No uncaught JS errors at boot (favicon 404 is expected noise)
    const fatalErrors = errors.filter(e =>
      !e.includes('favicon') &&
      !e.includes('service-worker') &&
      !e.includes('ServiceWorker')
    );
    expect(fatalErrors, `Unexpected console errors:\n${fatalErrors.join('\n')}`).toHaveLength(0);
  });

  test('onboarding or main nav shell is visible', async ({ page }) => {
    await page.goto('/');
    await page.waitForTimeout(6000);
    await enableAccessibility(page);

    // After hydration, either the onboarding "Skip" button OR the nav "Today" tab must be visible
    const skipVisible   = await page.getByRole('button', { name: 'Skip' }).count() > 0;
    const todayVisible  = await page.getByRole('tab', { name: 'Today' }).count() > 0;
    // Also accept "Set Your Direction" (first onboarding page title) as valid
    const titleVisible  = await page.getByText('Set Your Direction', { exact: true }).count() > 0;

    expect(
      skipVisible || todayVisible || titleVisible,
      'Expected onboarding screen or main nav bar to be visible after app load'
    ).toBeTruthy();
  });

  test('all 5 nav tabs visible after skipping onboarding', async ({ page }) => {
    await page.goto('/');
    await page.waitForTimeout(6000);
    await enableAccessibility(page);

    // If onboarding is active, click Skip → then Get Started on the last page
    const skipButton = page.getByRole('button', { name: 'Skip' });
    if (await skipButton.count()) {
      await skipButton.evaluate((element: HTMLElement) => element.click());
      await page.waitForTimeout(800);

      // Now on last onboarding page — click "Get Started"
      const getStarted = page.getByRole('button', { name: 'Get Started' });
      await expect(getStarted).toHaveCount(1, { timeout: 5000 });
      await getStarted.evaluate((element: HTMLElement) => element.click());
      await page.waitForTimeout(1000);
    }

    // All current bottom-navigation labels must be visible.
    const expectedTabs = ['Today', 'Plan', 'Habits', 'Grow', 'You'];
    for (const label of expectedTabs) {
      await expect(
        page.getByRole('tab', { name: label }),
        `Navigation tab "${label}" should be visible`
      ).toHaveCount(1, { timeout: 5000 });
    }
  });

});
