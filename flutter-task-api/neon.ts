import { defineConfig } from "@neon/config/v1";

export default defineConfig({
    preview: {
        functions: {
            "task-api": {
                name: "task collection api",
                source: "src/index.ts"
            }    
        }
    }
})