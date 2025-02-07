import { Point } from '../maths/point/Point';
import { FederatedEvent } from './FederatedEvent';
import type { PointData } from '../maths/point/PointData';
import type { Container } from '../scene/container/Container';
import type { PixiTouch } from './FederatedEvent';
export class FederatedMouseEvent extends FederatedEvent<
MouseEvent | PointerEvent | PixiTouch
> implements MouseEvent
{
    public altKey: boolean;
    public button: number;
    public buttons: number;
    public ctrlKey: boolean;
    public metaKey: boolean;
    public relatedTarget: EventTarget;
    public shiftKey: boolean;
    public client: Point = new Point();
    public get clientX(): number { return this.client.x; }
    public get clientY(): number { return this.client.y; }
    get x(): number { return this.clientX; }
    get y(): number { return this.clientY; }
    public detail: number;
    public movement: Point = new Point();
    get movementX(): number { return this.movement.x; }
    get movementY(): number { return this.movement.y; }
    public offset: Point = new Point();
    get offsetX(): number { return this.offset.x; }
    get offsetY(): number { return this.offset.y; }
    public global: Point = new Point();
    get globalX(): number { return this.global.x; }
    get globalY(): number { return this.global.y; }
    public screen: Point = new Point();
    get screenX(): number { return this.screen.x; }
    get screenY(): number { return this.screen.y; }
    public getLocalPosition<P extends PointData = Point>(container: Container, point?: P, globalPos?: PointData): P
    {
        return container.worldTransform.applyInverse<P>(globalPos || this.global, point);
    }
    public getModifierState(key: string): boolean
    {
        return 'getModifierState' in this.nativeEvent && this.nativeEvent.getModifierState(key);
    }
    // eslint-disable-next-line max-params
    public initMouseEvent(
        _typeArg: string,
        _canBubbleArg: boolean,
        _cancelableArg: boolean,
        _viewArg: Window,
        _detailArg: number,
        _screenXArg: number,
        _screenYArg: number,
        _clientXArg: number,
        _clientYArg: number,
        _ctrlKeyArg: boolean,
        _altKeyArg: boolean,
        _shiftKeyArg: boolean,
        _metaKeyArg: boolean,
        _buttonArg: number,
        _relatedTargetArg: EventTarget
    ): void
    {
        throw new Error('Method not implemented.');
    }
}