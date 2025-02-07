import type {JSHandle} from './JSHandle';
export interface ConsoleMessageLocation {
	url?: string;
	lineNumber?: number;
	columnNumber?: number;
}
export type ConsoleMessageType =
	| 'log'
	| 'debug'
	| 'info'
	| 'error'
	| 'warning'
	| 'dir'
	| 'dirxml'
	| 'table'
	| 'trace'
	| 'clear'
	| 'startGroup'
	| 'startGroupCollapsed'
	| 'endGroup'
	| 'assert'
	| 'profile'
	| 'profileEnd'
	| 'count'
	| 'timeEnd'
	| 'verbose';
export class ConsoleMessage {
	type: ConsoleMessageType;
	text: string;
	args: JSHandle[];
	previewString: string;
	#stackTraceLocations: ConsoleMessageLocation[];
	constructor({
		type,
		text,
		args,
		stackTraceLocations,
		previewString,
	}: {
		type: ConsoleMessageType;
		text: string;
		args: JSHandle[];
		stackTraceLocations: ConsoleMessageLocation[];
		previewString: string;
	}) {
		this.type = type;
		this.text = text;
		this.args = args;
		this.previewString = previewString;
		this.#stackTraceLocations = stackTraceLocations;
	}
	location(): ConsoleMessageLocation {
		return this.#stackTraceLocations[0] ?? {};
	}
	stackTrace(): ConsoleMessageLocation[] {
		return this.#stackTraceLocations;
	}
}