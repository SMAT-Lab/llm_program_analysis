import {DragDropModule} from '@angular/cdk/drag-drop';
import {Component, NgModule} from '@angular/core';
@Component({
  standalone: false,
  template: `
    <div cdkDropListGroup>
      <div cdkDropList>
        <div cdkDrag>
          <span cdkDragHandle>handle</span>
          <ng-template cdkDragPlaceholder>Placeholder</ng-template>
          <ng-template cdkDragPreview>Preview</ng-template>
        </div>
      </div>
    </div>
  `,
})
export class TestComponent {}
@NgModule({
  imports: [DragDropModule],
  declarations: [TestComponent],
  bootstrap: [TestComponent],
})
export class AppModule {}