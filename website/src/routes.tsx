import type { ReactElement } from 'react';
import { Docs } from './pages/Docs';
import { Home } from './pages/Home';
import { NotFound } from './pages/NotFound';
import { Support } from './pages/Support';

export type ClientEntry = 'home';

export interface Route {
  path: string;
  element: ReactElement;
  entry?: ClientEntry;
  meta?: {
    title?: string;
    description?: string;
  };
}

export const routes: Route[] = [
  { path: '/', element: <Home />, entry: 'home', meta: { title: 'YK Editor: the fast, native code editor and agent workspace' } },
  {
    path: '/docs',
    element: <Docs />,
    meta: { title: 'YK Editor Docs', description: 'YK Editor documentation, configuration, and features.' }
  },
  {
    path: '/support',
    element: <Support />,
    meta: { title: 'Support YK Editor', description: 'YK Editor is free and open source.' }
  },
  { path: '/404', element: <NotFound />, meta: { title: 'Page not found · YK Editor' } }
];
