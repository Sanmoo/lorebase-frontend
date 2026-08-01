import { defineConfig, devices } from '@playwright/test';
import { defineBddConfig } from 'playwright-bdd';
import dotenv from 'dotenv';

dotenv.config({ path: '.env.e2e' });

const testDir = defineBddConfig({
  features: 'features/**/*.feature',
  steps: ['steps/**/*.ts', 'support/fixtures.ts'],
});

const externalBaseURL = process.env.E2E_BASE_URL;
const localBaseURL = 'http://localhost:4173';

export default defineConfig({
  testDir,
  timeout: 180_000,
  reporter: [['html', { open: 'never' }], ['list']],
  use: {
    baseURL: externalBaseURL ?? localBaseURL,
    trace: 'retain-on-failure',
    screenshot: 'only-on-failure',
  },
  webServer: externalBaseURL
    ? undefined
    : {
        command: 'npx --yes serve -s ../build/web -l 4173',
        url: localBaseURL,
        reuseExistingServer: true,
        timeout: 30_000,
      },
  projects: [
    { name: 'setup', testDir: 'support', testMatch: 'auth.setup.ts' },
    {
      name: 'login',
      testDir,
      grep: /@login/,
      use: { ...devices['Desktop Chrome'], storageState: { cookies: [], origins: [] } },
    },
    {
      name: 'app',
      testDir,
      grepInvert: /@login/,
      dependencies: ['setup'],
      use: { ...devices['Desktop Chrome'], storageState: '.auth/user.json' },
    },
  ],
});
