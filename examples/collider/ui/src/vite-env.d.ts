/// <reference types="vite/client" />

import '@mui/material/IconButton/IconButton';

declare module '@mui/material/IconButton/IconButton' {
  interface IconButtonOwnProps {
    variant?: 'ghost' | 'jam';
  }
}
