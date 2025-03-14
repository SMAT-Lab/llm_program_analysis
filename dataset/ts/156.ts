import type { FlowGraphContext } from "../../../flowGraphContext";
import type { FlowGraphDataConnection } from "../../../flowGraphDataConnection";
import { RichTypeNumber } from "../../../flowGraphRichTypes";
import type { FlowGraphSignalConnection } from "../../../flowGraphSignalConnection";
import { FlowGraphExecutionBlockWithOutSignal } from "../../../flowGraphExecutionBlockWithOutSignal";
import type { IFlowGraphBlockConfiguration } from "../../../flowGraphBlock";
import { RegisterClass } from "../../../../Misc/typeStore";
export class FlowGraphThrottleBlock extends FlowGraphExecutionBlockWithOutSignal {
    public readonly duration: FlowGraphDataConnection<number>;
    public readonly reset: FlowGraphSignalConnection;
    public readonly timeRemaining: FlowGraphDataConnection<number>;
    constructor(config?: IFlowGraphBlockConfiguration) {
        super(config);
        this.reset = this._registerSignalInput("reset");
        this.duration = this.registerDataInput("duration", RichTypeNumber);
        this.timeRemaining = this.registerDataOutput("timeRemaining", RichTypeNumber);
    }
    public _execute(context: FlowGraphContext, callingSignal: FlowGraphSignalConnection): void {
        const lastExecutedTime = context._getExecutionVariable(this, "lastExecutedTime");
        const durationValue = this.duration.getValue(context);
        const currentTime = Date.now();
        if (callingSignal === this.reset || lastExecutedTime === undefined || currentTime - lastExecutedTime > durationValue) {
            //activate the output flow
            this.timeRemaining.setValue(0, context);
            this.out._activateSignal(context);
            context._setExecutionVariable(this, "lastExecutedTime", currentTime);
        } else {
            //activate the output flow after the remaining time
            const remaining = durationValue - (currentTime - lastExecutedTime);
            this.timeRemaining.setValue(remaining, context);
        }
    }
    public override getClassName(): string {
        return "FGThrottleBlock";
    }
}
RegisterClass("FGThrottleBlock", FlowGraphThrottleBlock);