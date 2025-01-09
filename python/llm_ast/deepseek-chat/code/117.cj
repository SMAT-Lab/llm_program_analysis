@pytest.mark.parametrize("block", get_blocks().values(), ids=lambda b: b.name)
def test_available_blocks(block: Type[Block]):
    execute_block_test(block())