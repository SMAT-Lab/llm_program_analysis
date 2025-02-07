import { Config, Disposable, Project } from "../index";
export class GitRepository {
    // Construction
    static open(path: string, options?: { refreshOnWindowFocus?: boolean | undefined }): GitRepository;
    constructor(
        path: string,
        options?: {
            refreshOnWindowFocus?: boolean | undefined;
            config?: Config | undefined;
            project?: Project | undefined;
        },
    );
    // Lifecycle
    destroy(): void;
    isDestroyed(): boolean;
    // Event Subscription
    onDidDestroy(callback: () => void): Disposable;
    onDidChangeStatus(callback: (event: RepoStatusChangedEvent) => void): Disposable;
    onDidChangeStatuses(callback: () => void): Disposable;
    // Repository Details
    getType(): "git";
    getPath(): string;
    getWorkingDirectory(): string;
    isProjectAtRoot(): boolean;
    relativize(): string;
    hasBranch(branch: string): boolean;
    getShortHead(path?: string): string;
    isSubmodule(path: string): boolean;
    getAheadBehindCount(reference: string, path?: string): { ahead: number; behind: number };
    getCachedUpstreamAheadBehindCount(path?: string): { ahead: number; behind: number };
    getConfigValue(key: string, path?: string): string;
    getOriginURL(path?: string): string;
    getUpstreamBranch(path?: string): string | null;
    getReferences(path?: string): { heads: string[]; remotes: string[]; tags: string[] };
    getReferenceTarget(reference: string, path?: string): string;
    // Reading Status
    isPathModified(path: string): boolean;
    isPathNew(path: string): boolean;
    isPathIgnored(path: string): boolean;
    getDirectoryStatus(path: string): number;
    getPathStatus(path: string): number;
    getCachedPathStatus(path: string): number | null;
    isStatusModified(status: number): boolean;
    isStatusNew(status: number): boolean;
    // Retrieving Diffs
    getDiffStats(path: string): { added: number; deleted: number };
    getLineDiffs(
        path: string,
        text: string,
    ): Array<{ oldStart: number; newStart: number; oldLines: number; newLines: number }>;
    // Checking Out
    checkoutHead(path: string): boolean;
    checkoutReference(reference: string, create: boolean): boolean;
}
export interface RepoStatusChangedEvent {
    path: string;
    pathStatus: number;
}