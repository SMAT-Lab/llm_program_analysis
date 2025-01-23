package quartz.org.quartz
public interface TriggerListener  {
    func getName() :String
    func triggerFired(trigger: Trigger, context: JobExecutionContext) : Unit
    func vetoJobExecution(trigger: Trigger, context: JobExecutionContext) : Bool
    func triggerMisfired(trigger: Trigger) : Unit
    func triggerComplete(trigger: Trigger, context: JobExecutionContext, triggerInstructionCode: CompletedExecutionInstruction) : Unit
}