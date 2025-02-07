import { connect } from 'react-redux';
import { translate } from '../../../base/i18n/functions';
import { IconDotsHorizontal } from '../../../base/icons/svg';
import AbstractButton, { IProps as AbstractButtonProps } from '../../../base/toolbox/components/AbstractButton';
interface IProps extends AbstractButtonProps {
    isOpen: boolean;
    onKeyDown: Function;
}
class OverflowToggleButton extends AbstractButton<IProps> {
    accessibilityLabel = 'toolbar.accessibilityLabel.moreActions';
    toggledAccessibilityLabel = 'toolbar.accessibilityLabel.closeMoreActions';
    icon = IconDotsHorizontal;
    label = 'toolbar.moreActions';
    toggledLabel = 'toolbar.moreActions';
    tooltip = 'toolbar.moreActions';
    _isToggled() {
        return this.props.isOpen;
    }
    _onKeyDown() {
        this.props.onKeyDown();
    }
}
export default connect()(translate(OverflowToggleButton));