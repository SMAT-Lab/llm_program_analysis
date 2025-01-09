def test_conn_retry_sync_function():
    retry_count = 0

    @conn_retry("Test", "Test function", max_retry=2, max_wait=0.1, min_wait=0.1)
    def test_function():
        nonlocal retry_count
        retry_count -= 1
        if retry_count > 0:
            raise ValueError("Test error")
        return "Success"

    retry_count = 2
    res = test_function()
    assert res == "Success"

    retry_count = 100
    with pytest.raises(ValueError) as e:
        test_function()
    assert str(e.value) == "Test error"