return {
    {
	"tweekmonster/django-plus.vim",
	ft = {"python", "htmldjango"},
	config = function()
	    -- Highlight template tags nicely
	    vim.g.django_disable_modeline = 1
	    vim.g.django_templates = 1
	    vim.g.django_highlight_tags = 1
	end,
    },
}
